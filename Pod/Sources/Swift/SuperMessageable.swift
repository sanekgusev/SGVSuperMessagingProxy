//
//  SuperMessageable.swift
//  Pods
//
//  Created by Aleksandr Gusev on 20/05/16.
//
//

/// SuperMessageable: Instances of conforming classes will be able to vend super proxy objects
public protocol SuperMessageable: class { }

public extension SuperMessageable {
    
    public var superProxy: AnyObject? {
        return SuperMessagingProxy(object: self)
    }
    
    public func superProxy<Ancestor: AnyObject>(forAncestor ancestorClass: Ancestor.Type) -> Ancestor? {
        return SuperMessagingProxy(object: self,
                                   ancestorClass: ancestorClass)
            .flatMap({ unsafeBitCast($0, to: Ancestor.self) })
    }

    public static var superProxy: AnyClass? {
        return SuperMessagingProxy(object: self)
            .flatMap({ unsafeBitCast($0, to: AnyClass.self) })
    }

    public static func superProxy(forAncestor ancestorClass: AnyClass) -> AnyClass? {
        return SuperMessagingProxy(object: self,
                                   ancestorClass: ancestorClass)
            .flatMap({ unsafeBitCast($0, to: AnyClass.self) })
    }
}
