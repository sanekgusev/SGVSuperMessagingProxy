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
    
    override class func classSays() -> String {
        return "Class Nyan"
    }
    
    override class var classAwesomenessLevel: Int {
        return 9
    }
}
