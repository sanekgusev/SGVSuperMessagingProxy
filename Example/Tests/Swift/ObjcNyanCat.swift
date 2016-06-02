//
//  ObjcNyanCat.swift
//  SuperMessagingProxyTests
//
//  Created by Aleksandr Gusev on 01/06/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

import Foundation

@objc
class ObjcNyanCat: ObjcCat {
    @objc
    dynamic override func says() -> String {
        return "Nyan"
    }
    
    @objc
    dynamic override var exclamation: String {
        return "Nyan!"
    }
    
    private var _awesomenessLevel: Int = 10
    
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
        return "Nyan"
    }
    
    @objc
    dynamic override class var awesomenessLevel: Int {
        return 10
    }
}
