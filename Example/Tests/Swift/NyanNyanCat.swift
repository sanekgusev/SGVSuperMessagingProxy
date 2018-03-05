//
//  NyanNyanCat.swift
//  SGVSuperMessagingProxy
//
//  Created by Aleksandr Gusev on 19/05/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

class NyanNyanCat: NyanCat {
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
        return Int.max
    }
}
