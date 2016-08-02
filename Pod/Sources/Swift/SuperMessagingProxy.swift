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

private enum MsgSendSuperDispatchMode {
    case Normal
    case Stret
}

private enum MsgSendSuperFunction: String {
    case MsgSendSuper
    case MsgSendSuper2
}

public final class SuperMessagingProxy {
    
    private let `super`: objc_super
    private let object: AnyObject?
    
    public convenience init?(object: AnyObject, ancestorClass: AnyClass, retainsObject: Bool = true) {
        guard let classOfObject = object_getClass(object) where
            isClass(classOfObject, strictSubclassOf: ancestorClass),
            let proxySubclass = uniqueProxySubclassFor(proxiedObjectClass: classOfObject, superFunction: .MsgSendSuper) else {
                return nil
        }
        
        self.init(object: object, retainsObject: retainsObject, classForSuper: ancestorClass, proxySubclass: proxySubclass)
    }
    
    public convenience init?(object: AnyObject, retainsObject: Bool = true) {
        guard let classOfObject = object_getClass(object),
            _ = class_getSuperclass(classOfObject),
            let proxySubclass = uniqueProxySubclassFor(proxiedObjectClass: classOfObject, superFunction: .MsgSendSuper2) else {
                return nil
        }
        self.init(object: object, retainsObject: retainsObject, classForSuper: classOfObject, proxySubclass: proxySubclass)
    }
    
    private init?(object: AnyObject, retainsObject: Bool, classForSuper: AnyClass, proxySubclass: AnyClass) {
        `super` = {
            var `super` = $0
            `super`.receiver = .passUnretained(object)
            `super`.super_class = classForSuper
            return `super`
        }(objc_super())
        
        self.object = retainsObject ? object : nil
        object_setClass(self, proxySubclass)
    }
    
    deinit {
        if let proxySubclass = object_getClass(self),
            proxyClass = class_getSuperclass(proxySubclass),
            rootClass = class_getSuperclass(proxyClass) {
            object_setClass(self, rootClass)
            objc_disposeClassPair(proxySubclass)
        }
    }
    
    @objc
    public class func resolveInstanceMethod(sel: Selector) -> Bool {
        guard let (originalClass, superFunction) = originalObjectClassAndSuperFunctionFrom(proxySubclass: self),
            superClass = class_getSuperclass(originalClass) else {
            return false
        }
        let method = class_getInstanceMethod(superClass, sel)
        guard method != nil else {
            NSException.raise(NSInternalInconsistencyException, format: "No dynamically dispatched method with selector \(sel) is available on any of the superclasses of \(originalClass)", arguments: CVaListPointer(_fromUnsafeMutablePointer: nil))
            return false
        }
        
        return addSuperForwardingMethodTo(proxySubclass: self,
                                          forSelector: sel,
                                          typeEncoding: method_getTypeEncoding(method),
                                          usingSuperFunction: superFunction)
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


private func dispatchMode(forTypeEncoding typeEncoding: UnsafePointer<Int8>) -> MsgSendSuperDispatchMode {
    let dispatchMode: MsgSendSuperDispatchMode
    #if arch(arm64)
         //arm64 doesn't use stret dispatch at all, yay!
        dispatchMode = .Normal
    #elseif arch(arm) || arch (x86_64) || arch(i386)
        var returnTypeActualSize = 0
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
            dispatchMode = returnTypeActualSize > (strideof(UInt) * 2) ? .Stret : .Normal
        #endif
    #else
        //error - Unknown architecture
    #endif
    
    return dispatchMode
}

private let nonForwardedMethodSelectors = Set([
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

private func uniqueProxySubclassFor(proxiedObjectClass objectClass: AnyClass,
                                                       superFunction: MsgSendSuperFunction) -> AnyClass? {
    let UUIDString = String(NSUUID().UUIDString.characters.filter({ $0 != "-" }))
    let proxySubclassName = "\(NSStringFromClass(SuperMessagingProxy))\(UUIDString)_\(superFunction)_\(NSStringFromClass(objectClass))"
    guard let proxySubclass = objc_allocateClassPair(SuperMessagingProxy.self, proxySubclassName, 0),
        proxySuperclass = class_getSuperclass(SuperMessagingProxy.self) else {
        return nil
    }
    
    // SwiftObject has some stuff already implemeted which we do not want.
    // For every subclass of our proxy we will reimplement those methods
    // to use our trampolines instead.
    // Scary things starting with an underscore and memory-management related
    // stuff are kept, though.
    
    var outCount: UInt32 = 0
    
    let methods = class_copyMethodList(proxySuperclass, &outCount)
    let methodCount = Int(outCount)
    defer {
        methods.destroy(methodCount)
    }
    
    (0..<methodCount).forEach { index in
        let method = methods[index]
        let selector = method_getName(method)
        if String(selector).hasPrefix("_") ||
            nonForwardedMethodSelectors.contains(selector) {
            return
        }
        let typeEncoding = method_getTypeEncoding(method)
        addSuperForwardingMethodTo(proxySubclass: proxySubclass,
            forSelector: selector,
            typeEncoding: typeEncoding,
            usingSuperFunction: superFunction)
    }
    
    objc_registerClassPair(proxySubclass)
    return proxySubclass
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

@_silgen_name("SGVAddressOfObjcMsgSendSuperTrampolineSwift")
private func SGVAddressOfObjcMsgSendSuperTrampolineSwift() -> UInt

@_silgen_name("SGVAddressOfObjcMsgSendSuper2TrampolineSwift")
private func SGVAddressOfObjcMsgSendSuper2TrampolineSwift() -> UInt

@_silgen_name("SGVAddressOfObjcMsgSendSuperStretTrampolineSwift")
private func SGVAddressOfObjcMsgSendSuperStretTrampolineSwift() -> UInt

@_silgen_name("SGVAddressOfObjcMsgSendSuper2StretTrampolineSwift")
private func SGVAddressOfObjcMsgSendSuper2StretTrampolineSwift() -> UInt

private func addSuperForwardingMethodTo(proxySubclass proxySubclass: AnyClass,
                                                      forSelector selector: Selector,
                                                                  typeEncoding: UnsafePointer<Int8>,
                                                  usingSuperFunction superFunction: MsgSendSuperFunction) -> Bool {
    let mode = dispatchMode(forTypeEncoding: typeEncoding)
    
    let address: UInt
    switch mode {
    case .Normal:
        switch superFunction {
        case .MsgSendSuper:
            address = SGVAddressOfObjcMsgSendSuperTrampolineSwift()
        case .MsgSendSuper2:
            address = SGVAddressOfObjcMsgSendSuper2TrampolineSwift()
        }
    case .Stret:
        switch superFunction {
        case .MsgSendSuper:
            address = SGVAddressOfObjcMsgSendSuperStretTrampolineSwift()
        case .MsgSendSuper2:
            address = SGVAddressOfObjcMsgSendSuper2StretTrampolineSwift()
        }
    }
    
    let imp = IMP(bitPattern: address)
    
    guard class_addMethod(proxySubclass, selector, imp, typeEncoding) else {
        print("SuperMessagingProxy has failed to add method for selector \(selector) to class \(proxySubclass)")
        return false
    }
    return true
}
