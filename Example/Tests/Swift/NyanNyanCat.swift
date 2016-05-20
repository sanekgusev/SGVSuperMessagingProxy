//
//  NyanNyanCat.swift
//  SGVSuperMessagingProxy
//
//  Created by Aleksandr Gusev on 19/05/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

import Foundation

class NyanNyanCat: NyanCat {
    dynamic override func says() -> String {
        return "Nyan-nyan"
    }
    
    dynamic override var exclamation: String {
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
    
    dynamic override class func says() -> String {
        return "Nyan-nyan"
    }
    
    dynamic override class var awesomenessLevel: Int {
        return Int.max
    }
}
