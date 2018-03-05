//
//  SuperMessageable.swift
//  Pods
//
//  Created by Aleksandr Gusev on 20/05/16.
//
//

import ObjectiveC.runtime

/// SuperMessageable: Instances of conforming classes will be able to vend super proxy objects
public protocol SuperMessageable: class { }

public extension SuperMessageable {
    
    public var superProxy: AnyObject? {
        return object_getClass(self)
            .flatMap({ class_getSuperclass($0) })
            .flatMap({ SuperMessagingProxy(object: self,
                                           ancestorClass: $0) })
    }
    
    public func superProxy<Ancestor: AnyObject>(forAncestor ancestorClass: Ancestor.Type) -> Ancestor? {
        return SuperMessagingProxy(object: self,
                                   ancestorClass: ancestorClass)
            .flatMap({ unsafeBitCast($0, to: Ancestor.self) })
    }

    public static var superProxy: AnyObject? {
        return object_getClass(self)
            .flatMap({ class_getSuperclass($0) })
            .flatMap({ SuperMessagingProxy(object: self,
                                           ancestorClass: $0) })
    }

    public static func superProxy(forAncestor ancestorClass: AnyClass) -> AnyObject? {
        return SuperMessagingProxy(object: self,
                                   ancestorClass: ancestorClass)
    }
}
