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
    
    public func superProxy(forAncestor ancestorClass: AnyClass) -> AnyObject? {
        return SuperMessagingProxy(object: self, ancestorClass: ancestorClass)
    }
}
