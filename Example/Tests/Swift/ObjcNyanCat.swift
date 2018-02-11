//
//  ObjcNyanCat.swift
//  SuperMessagingProxyTests
//
//  Created by Aleksandr Gusev on 01/06/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

class ObjcNyanCat: ObjcCat {

    override func says() -> String {
        return "Nyan"
    }
    
    override var exclamation: String {
        return "Nyan!"
    }
    
    private var _awesomenessLevel: Int = 10
    
    override var awesomenessLevel: Int {
        get {
            return _awesomenessLevel
        }
        set {
            _awesomenessLevel = newValue
        }
    }
    
    override class func says() -> String {
        return "Nyan"
    }
    
    override class var awesomenessLevel: Int {
        return 10
    }
}
