//
//  ObjcCat.swift
//  SuperMessagingProxyTests
//
//  Created by Aleksandr Gusev on 01/06/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

import Foundation

class ObjcCat: NSObject {

    @objc
    dynamic func says() -> String {
        return Cat.classSays()
    }
    
    @objc
    dynamic var exclamation: String {
        return "Meouw!"
    }
    
    @objc
    dynamic var awesomenessLevel = 5
    
    @objc
    dynamic class func classSays() -> String {
        return "Purr"
    }
    
    @objc
    dynamic class var classAwesomenessLevel: Int {
        return 4
    }
}
