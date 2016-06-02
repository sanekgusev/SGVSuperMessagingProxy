
//
//  ObjcNyanNyanCat.swift
//  SuperMessagingProxyTests
//
//  Created by Aleksandr Gusev on 01/06/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

import Foundation

@objc
class ObjcNyanNyanCat: ObjcNyanCat {
    @objc
    dynamic override func says() -> String {
        return "Nyan-nyan"
    }
    
    @objc
    dynamic override var exclamation: String {
        return "Nyan! Nyan! Nyan!!!"
    }
    
    private var _awesomenessLevel: Int = Int.max
    
    @objc
    dynamic override var awesomenessLevel: Int {
        get {
            return _awesomenessLevel
        }
        set {
            _awesomenessLevel = newValue
        }
    }
    
    @objc
    dynamic override class func says() -> String {
        return "Nyan-nyan"
    }
    
    @objc
    dynamic override class var awesomenessLevel: Int {
        return Int.max
    }
}