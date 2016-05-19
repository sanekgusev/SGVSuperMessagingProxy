//
//  SGVSuperMessagingProxyTests.swift
//  SGVSuperMessagingProxyTests
//
//  Created by Aleksandr Gusev on 19/05/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

import XCTest
import SGVSuperMessagingProxy

class SGVSuperMessagingProxyTests: XCTestCase {
    
    let nyanNyanCat = NyanNyanCat()
    
    func testImmediateSuperclass() {
        let proxy = Proxy.superFor(nyanNyanCat)
        XCTAssertEqual(proxy.says(), NyanCat().says())
    }
    
    func testNonImmediateSuperclass() {
        let proxy = Proxy.superFor(nyanNyanCat, ancestorClass: Cat.self)
        XCTAssertEqual(proxy.says(), Cat().says())
    }
    
}
