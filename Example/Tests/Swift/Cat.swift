//
//  Cat.swift
//  SGVSuperMessagingProxy
//
//  Created by Aleksandr Gusev on 19/05/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

import Foundation

class Cat {
    dynamic func says() -> String {
        return Cat.says()
    }
    
    dynamic var exclamation: String {
        return "Meouw!"
    }
    
    dynamic var awesomenessLevel = 5
    
    dynamic class func says() -> String {
        return "Purr"
    }
    
    dynamic class var awesomenessLevel: Int {
        return 5
    }
    
    dynamic func baseClassMethod() -> String {
        return "I am a base cat"
    }
}
