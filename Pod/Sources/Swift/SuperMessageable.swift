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
    
    public var superProxy: Self? {
        return SuperMessagingProxy(object: self).map({ unsafeBitCast($0, Self.self) })
    }
    
    public func superProxy(forAncestor ancestorClass: AnyClass) -> Self? {
        return SuperMessagingProxy(object: self, ancestorClass: ancestorClass).map({ unsafeBitCast($0, Self.self) })
    }
}
