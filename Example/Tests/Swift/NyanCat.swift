//
//  NyanCat.swift
//  SGVSuperMessagingProxy
//
//  Created by Aleksandr Gusev on 19/05/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

import Foundation

class NyanCat: Cat {
    dynamic override func says() -> String {
        return "Nyan"
    }
    
    dynamic override var exclamation: String {
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
    
    dynamic override class func says() -> String {
        return "Nyan"
    }
    
    dynamic override class var awesomenessLevel: Int {
        return 10
    }
}

