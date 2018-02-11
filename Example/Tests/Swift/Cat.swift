//
//  Cat.swift
//  SGVSuperMessagingProxy
//
//  Created by Aleksandr Gusev on 19/05/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

import Foundation

class Cat {
    @objc dynamic func says() -> String {
        return Cat.says()
    }
    
    @objc dynamic var exclamation: String {
        return "Meouw!"
    }
    
    @objc dynamic var awesomenessLevel = 5
    
    @objc dynamic class func says() -> String {
        return "Purr"
    }
    
    @objc dynamic class var awesomenessLevel: Int {
        return 5
    }
    
    @objc dynamic func baseClassMethod() -> String {
        return "I am a base cat"
    }
}
