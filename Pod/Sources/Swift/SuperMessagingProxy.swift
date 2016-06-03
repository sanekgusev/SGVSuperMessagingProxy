//
//  SuperMessagingProxy.swift
//  Pods
//
//  Created by Aleksandr Gusev on 27/05/16.
//
//

import Foundation
import ObjectiveC.runtime
import ObjectiveC.message
import SGVSuperMessagingProxyPrivate

private enum MsgSendSuperDispatchMode {
    case Normal
    case Stret
}

private enum MsgSendSuperFunction: String {
    case MsgSendSuper
    case MsgSendSuper2
}

public final class SuperMessagingProxy {
    
    private var _super: objc_super
    private let object: AnyObject?
    
    public init?(object: AnyObject, ancestorClass: AnyClass, retainsObject: Bool = true) {
        guard let classOfObject = object_getClass(object) where
            isClass(classOfObject, strictSubclassOf: ancestorClass) else {
                return nil
        }
        guard let proxySubclass = proxySubclassFor(proxiedObjectClass: classOfObject, superFunction: .MsgSendSuper) else {
            return nil
        }
        _super = objc_super()
        _super.receiver = .passUnretained(object)
        _super.super_class = ancestorClass
        self.object = retainsObject ? object : nil
        object_setClass(self, proxySubclass)
    }
    
    public init?(object: AnyObject, retainsObject: Bool = true) {
        guard let classOfObject = object_getClass(object),
            _ = class_getSuperclass(classOfObject) else {
                return nil
        }
        guard let proxySubclass = proxySubclassFor(proxiedObjectClass: classOfObject, superFunction: .MsgSendSuper2) else {
            return nil
        }
        _super = objc_super()
        _super.receiver = .passRetained(object)
        _super.super_class = classOfObject
        self.object = retainsObject ? object : nil
        object_setClass(self, proxySubclass)
    }
    
    @objc
    public class func resolveInstanceMethod(sel: Selector) -> Bool {
        guard let (originalClass, superFunction) = originalObjectClassAndSuperFunctionFrom(proxySubclass: self) else {
            return false
        }
        let method = class_getInstanceMethod(originalClass, sel)
        
        return addTo(proxySubclass: self, trampolineMethod: method, usingSuperFunction: superFunction)
    }
    
    @objc
    public class func accessInstanceVariablesDirectly() -> Bool {
        return false
    }
}

private func isClass(aClass: AnyClass, strictSubclassOf possibleSuperclass: AnyClass) -> Bool {
    var superclass: AnyClass? = class_getSuperclass(aClass)
    while superclass != nil {
        if superclass == possibleSuperclass {
            return true
        }
        superclass = class_getSuperclass(superclass)
    }
    return false
}

private func originalObjectClassAndSuperFunctionFrom(proxySubclass proxySubclass: AnyClass) -> (originalObjectSublcass: AnyClass, superFunction: MsgSendSuperFunction)? {
    let components = NSStringFromClass(proxySubclass).characters.split("_").map(String.init)
    guard components.count == 3,
        let originalObjectClassName = components.last,
        originalObjectSubclass = NSClassFromString(originalObjectClassName),
        superFunction = MsgSendSuperFunction(rawValue: components[1]) else {
        return nil
    }
    return (originalObjectSubclass, superFunction)
}

private func dispatchMode(forTypeEncoding typeEncoding: UnsafePointer<Int8>) -> MsgSendSuperDispatchMode {
    let dispatchMode: MsgSendSuperDispatchMode
    #if arch(arm64)
         //arm64 doesn't use stret dispatch at all, yay!
        dispatchMode = .Normal
    #elseif arch(arm) || arch (x86_64) || arch(i386)
        var returnTypeActualSize = 0;
        NSGetSizeAndAlignment(typeEncoding,
                              &returnTypeActualSize,
                              nil)
        #if arch(arm)
            // On arm, stret dispatch is used whenever the return type
            // does not fit into a single register
            dispatchMode = returnTypeActualSize > strideof(UInt) ? .Stret : .Normal
        #elseif arch(x86_64) || arch(i386)
            // On i386 and x86-64, stret dispatch is used whenever the return type
            // doesn't fit into two registers
            dispatchMode = returnTypeActualSize > (strideof(UInt) * 2) ? .Stret : .Normal;
        #endif
    #else
        //error - Unknown architecture
    #endif
    
    return dispatchMode
}

private func addTo(proxySubclass proxySubclass: AnyClass,
                                 trampolineMethod method: Method,
                                                  usingSuperFunction superFunction: MsgSendSuperFunction) -> Bool {
    let typeEncoding = method_getTypeEncoding(method)
    let mode = dispatchMode(forTypeEncoding: typeEncoding)
    
    let selector = method_getName(method)
    
    let function: @convention(c) () -> Void
    switch mode {
    case .Normal:
        switch superFunction {
        case .MsgSendSuper:
            function = SGVObjcMsgSendSuperTrampolineSwift
        case .MsgSendSuper2:
            function = SGVObjcMsgSendSuper2TrampolineSwift
        }
    case .Stret:
        switch superFunction {
        case .MsgSendSuper:
            function = SGVObjcMsgSendSuperStretTrampolineSwift
        case .MsgSendSuper2:
            function = SGVObjcMsgSendSuper2StretTrampolineSwift
        }
    }
    
    let imp = IMP(bitPattern: unsafeBitCast(function, UInt.self))
    
    guard class_addMethod(proxySubclass, selector, imp, typeEncoding) else {
        print("SuperMessagingProxy has failed to add method for selector \(selector) to class \(proxySubclass)")
        return false
    }
    return true
}

private let nonForwardedMethodNames: Set<Selector> = Set([
    "zone",
    "retain",
    "release",
    "autorelease",
    "retainCount",
    "dealloc",
    "finalize",
    "retainWeakReference",
    "allowsWeakReference",
    ].map({ Selector($0) }))

private func proxySubclassFor(proxiedObjectClass objectClass: AnyClass,
                                                 superFunction: MsgSendSuperFunction) -> AnyClass? {
    let proxySubclassName = "\(NSStringFromClass(SuperMessagingProxy))_\(superFunction)_\(NSStringFromClass(objectClass))"
    guard let proxySubclass = objc_allocateClassPair(SuperMessagingProxy.self, proxySubclassName, 0) else {
        return objc_lookUpClass(proxySubclassName)
    }
    // SwiftObject has some stuff already implemeted which we do not want.
    // For every subclass of our proxy we will reimplement those methods
    // to use our trampolines instead.
    // Scary things starting with an underscore and memory-management related
    // stuff are kept, though.
    
    var outCount: UInt32 = 0
    
    let proxySuperclass: AnyClass! = class_getSuperclass(SuperMessagingProxy.self)
    
    let methods = class_copyMethodList(proxySuperclass, &outCount)
    defer {
        methods.destroy(Int(outCount))
    }
    
    (0..<Int(outCount)).forEach({ index in
        let method = methods[index]
        let selector: Selector = method_getName(method)
        if String(selector).hasPrefix("_") ||
            nonForwardedMethodNames.contains(selector) {
            return
        }
        addTo(proxySubclass: proxySubclass, trampolineMethod: method, usingSuperFunction: superFunction)
    })
    
    objc_registerClassPair(proxySubclass)
    return proxySubclass
}