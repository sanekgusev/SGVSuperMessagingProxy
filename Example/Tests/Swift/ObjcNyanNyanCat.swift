
//
//  ObjcNyanNyanCat.swift
//  SuperMessagingProxyTests
//
//  Created by Aleksandr Gusev on 01/06/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

class ObjcNyanNyanCat: ObjcNyanCat {
    override func says() -> String {
        return "Nyan-nyan"
    }
    
    override var exclamation: String {
        return "Nyan! Nyan! Nyan!!!"
    }
    
    private var _awesomenessLevel: Int = Int.max
    
    override var awesomenessLevel: Int {
        get {
            return _awesomenessLevel
        }
        set {
            _awesomenessLevel = newValue
        }
    }
    
    override class func classSays() -> String {
        return "Class Nyan-nyan"
    }
    
    override class var classAwesomenessLevel: Int {
        return Int.max - 1
    }
}
