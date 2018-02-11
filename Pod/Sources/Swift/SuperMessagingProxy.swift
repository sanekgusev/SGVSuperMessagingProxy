//
//  SuperMessagingProxy.swift
//  Pods
//
//  Created by Aleksandr Gusev on 27/05/16.
//
//

import ObjectiveC.runtime
import ObjectiveC.message

public final class SuperMessagingProxy {

    /// These 2 properties mimic the layout of `objc_super` struct.
    /// Trampoline functions will use the address of SuperMessagingProxy's `self` +
    /// the offset of `_objectAddress` to calculate the address for the first
    /// argument of the correspoding `objc_msgSendSuper` function.
    private let _objectAddress: UInt
    private let _superclass: AnyClass

    private let object: AnyObject?

    // MARK: Init/deinit
    
    public convenience init?(object: AnyObject,
                             ancestorClass: AnyClass,
                             retainsObject: Bool = true) {
        let classOfObject: AnyClass = type(of: object)
        guard type(of: self).isClass(aClass: classOfObject, strictSubclassOf: ancestorClass),
            let proxySubclass = type(of: self).uniqueProxySubclass(for: classOfObject,
                                                                   superFunction: .msgSendSuper) else {
                                                                    return nil
        }

        self.init(object: object,
                  retainsObject: retainsObject,
                  classForSuper: ancestorClass,
                  proxySubclass: proxySubclass)
    }

    public convenience init?(object: AnyObject, retainsObject: Bool = true) {
        let classOfObject: AnyClass = type(of: object)
        guard class_getSuperclass(classOfObject) != nil,
            let proxySubclass = type(of: self).uniqueProxySubclass(for: classOfObject,
                                                                   superFunction: .msgSendSuper2) else {
                                                                    return nil
        }
        self.init(object: object,
                  retainsObject: retainsObject,
                  classForSuper: classOfObject,
                  proxySubclass: proxySubclass)
    }

    private init(object: AnyObject,
                 retainsObject: Bool,
                 classForSuper: AnyClass,
                 proxySubclass: AnyClass) {
        _objectAddress = unsafeBitCast(object, to: UInt.self)
        _superclass = classForSuper
        self.object = retainsObject ? object : nil
        object_setClass(self, proxySubclass)
    }

    deinit {
        if let proxySubclass = object_getClass(self),
            let proxyClass = class_getSuperclass(proxySubclass),
            let rootClass = class_getSuperclass(proxyClass) {
            
            object_setClass(self, rootClass)
            objc_disposeClassPair(proxySubclass)
        }
    }

    // MARK: Objective-C runtime
    
    @objc
    private class func resolveInstanceMethod(_ sel: Selector!) -> Bool {
        guard let (proxiedObjectClass, superFunction) = proxiedObjectClassAndSuperFunction else {
            fatalError("SuperMessagingProxy has failed to retrieve proxied object class and super function kind from proxy's class name — this should never happen")
        }
        guard let proxiedObjectSuperclass = class_getSuperclass(proxiedObjectClass) else {
            fatalError("SuperMessagingProxy has failed to retrieve proxied object's superclass — this should never happen")
        }
        guard let method = class_getInstanceMethod(proxiedObjectSuperclass, sel),
            let typeEncoding = method_getTypeEncoding(method) else {
                fatalError("SuperMessagingProxy: No dynamically dispatched method with selector \(sel) is available on any of the superclasses of \(proxiedObjectClass)!")
        }
        
        let result = addSuperForwardingMethod(to: self,
                                              for: sel,
                                              typeEncoding: typeEncoding,
                                              using: superFunction)
        if !result {
            NSLog("SuperMessagingProxy has failed to add super forwarding method for selector \(sel), object class \(proxiedObjectClass)")
        }
        return result
    }
    
    @objc
    private class var accessInstanceVariablesDirectly: Bool {
        return false
    }

    // MARK: Private

    private static func isClass(aClass: AnyClass, strictSubclassOf possibleSuperclass: AnyClass) -> Bool {
        var superclass: AnyClass? = class_getSuperclass(aClass)
        while superclass != nil {
            if superclass == possibleSuperclass {
                return true
            }
            superclass = class_getSuperclass(superclass)
        }
        return false
    }

    private enum MsgSendSuperDispatchMode {
        case normal
        case stret
    }

    private static func dispatchMode(for typeEncoding: UnsafePointer<Int8>) -> MsgSendSuperDispatchMode {
        let dispatchMode: MsgSendSuperDispatchMode
        #if arch(arm64)
            //arm64 doesn't use stret dispatch at all, yay!
            dispatchMode = .normal
        #elseif arch(arm) || arch (x86_64) || arch(i386)
            var returnTypeActualSize = 0
            NSGetSizeAndAlignment(typeEncoding,
                                  &returnTypeActualSize,
                                  nil)
            #if arch(arm)
                // On arm, stret dispatch is used whenever the return type
                // does not fit into a single register
                dispatchMode = returnTypeActualSize > strideof(UInt) ? .stret : .normal
            #elseif arch(x86_64) || arch(i386)
                // On i386 and x86-64, stret dispatch is used whenever the return type
                // doesn't fit into two registers
                dispatchMode = returnTypeActualSize > (MemoryLayout<UInt>.stride * 2) ? .stret : .normal
            #endif
        #else
            //error - Unknown architecture
        #endif

        return dispatchMode
    }

    private static let nonForwardedMethodSelectors = Set([
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

    private enum MsgSendSuperFunction: String {
        case msgSendSuper
        case msgSendSuper2
    }

    private static func uniqueProxySubclass(for proxiedObjectClass: AnyClass,
                                            superFunction: MsgSendSuperFunction) -> AnyClass? {
        let UUIDString = NSUUID().uuidString.filter({ $0 != "-" })
        let proxySubclassName = NSStringFromClass(self) +
        "\(UUIDString)_\(superFunction)_\(NSStringFromClass(proxiedObjectClass))"
        guard let proxySubclass = objc_allocateClassPair(self, proxySubclassName, 0),
            let rootClass = class_getSuperclass(self) else {
                return nil
        }

        // SwiftObject has some stuff already implemeted which we do not want.
        // For every subclass of our proxy we will reimplement those methods
        // to use our trampolines instead.
        // Scary things starting with an underscore and memory-management related
        // stuff are kept, though.

        var count: UInt32 = 0
        guard let methodsPointer = class_copyMethodList(rootClass, &count) else {
            NSLog("SuperMessagingProxy has failed to get the method list of the root class '\(rootClass)'")
            return nil
        }
        defer {
            methodsPointer.deinitialize(count: numericCast(count))
            methodsPointer.deallocate(capacity: numericCast(count))
        }
        let methods = UnsafeBufferPointer(start: methodsPointer,
                                          count: numericCast(count))
        methods.forEach { method in
            let selector = method_getName(method)
            let selectorString = selector.description
            if selectorString.hasPrefix("_") ||
                selectorString.hasSuffix("_") ||
                nonForwardedMethodSelectors.contains(selector) {
                return
            }
            if let typeEncoding = method_getTypeEncoding(method) {
                addSuperForwardingMethod(to: proxySubclass,
                                         for: selector,
                                         typeEncoding: typeEncoding,
                                         using: superFunction)
            } else {
                NSLog("SuperMessagingProxy has failed to get type encoding for root class' method with selector \(selector), not forwarding")
            }
        }

        objc_registerClassPair(proxySubclass)

        return proxySubclass
    }

    private static var proxiedObjectClassAndSuperFunction: (originalObjectSublcass: AnyClass, superFunction: MsgSendSuperFunction)? {
        let components = NSStringFromClass(self).split(separator: "_")
        guard components.count == 3,
            let originalObjectSubclass = NSClassFromString(String(components[2])),
            let superFunction = MsgSendSuperFunction(rawValue: String(components[1])) else {
                return nil
        }
        return (originalObjectSubclass, superFunction)
    }

    @discardableResult
    private static func addSuperForwardingMethod(to proxySubclass: AnyClass,
                                                 for selector: Selector,
                                                 typeEncoding: UnsafePointer<Int8>,
                                                 using superFunction: MsgSendSuperFunction) -> Bool {
        let superForwaringImpAddress: UInt = {
            switch dispatchMode(for: typeEncoding) {
            case .normal:
                switch superFunction {
                case .msgSendSuper:
                    return SGVAddressOfObjcMsgSendSuperTrampolineSwift()
                case .msgSendSuper2:
                    return SGVAddressOfObjcMsgSendSuper2TrampolineSwift()
                }
            case .stret:
                switch superFunction {
                case .msgSendSuper:
                    return SGVAddressOfObjcMsgSendSuperStretTrampolineSwift()
                case .msgSendSuper2:
                    return SGVAddressOfObjcMsgSendSuper2StretTrampolineSwift()
                }
            }
        }()

        guard let superForwardingImp = IMP(bitPattern: superForwaringImpAddress),
            class_addMethod(proxySubclass,
                            selector,
                            superForwardingImp,
                            typeEncoding) else {
                                NSLog("SuperMessagingProxy has failed to add method for selector \(selector) to class \(proxySubclass)")
                                return false
        }
        return true
    }
}

@_silgen_name("SGVAddressOfObjcMsgSendSuperTrampolineSwift")
private func SGVAddressOfObjcMsgSendSuperTrampolineSwift() -> UInt

@_silgen_name("SGVAddressOfObjcMsgSendSuper2TrampolineSwift")
private func SGVAddressOfObjcMsgSendSuper2TrampolineSwift() -> UInt

@_silgen_name("SGVAddressOfObjcMsgSendSuperStretTrampolineSwift")
private func SGVAddressOfObjcMsgSendSuperStretTrampolineSwift() -> UInt

@_silgen_name("SGVAddressOfObjcMsgSendSuper2StretTrampolineSwift")
private func SGVAddressOfObjcMsgSendSuper2StretTrampolineSwift() -> UInt
