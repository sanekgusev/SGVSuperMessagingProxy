//
//  SuperMessagingProxyTests.swift
//  SuperMessagingProxyTests
//
//  Created by Aleksandr Gusev on 20/05/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

import XCTest
import SGVSuperMessagingProxy

extension Cat: SuperMessageable {}

extension NSObject: SuperMessageable {}

class SuperMessagingProxyTests: XCTestCase {
    
    var nyanNyanCat = NyanNyanCat()
    
    override func setUp() {
        super.setUp()
        nyanNyanCat = NyanNyanCat()
    }
    
    func testSuccessfulProxyCreationFromValidClass() {
        XCTAssertNotNil(nyanNyanCat.superProxy)
        XCTAssertNotNil(nyanNyanCat.superProxy(forAncestor: Cat.self))
    }
    
    func testFailedProxyCreationFromRootClass() {
        XCTAssertNil(NSObject().superProxy)
    }
    
    func testFailedProxyCreationFromNotAnAncestorClass() {
        XCTAssertNil(nyanNyanCat.superProxy(forAncestor: NyanNyanCat.self))
    }
    
    func testImmediateSuperclass() {
        guard let proxy = nyanNyanCat.superProxy else {
            XCTFail()
            return
        }
        XCTAssertEqual(proxy.says(), NyanCat().says())
        XCTAssertEqual(proxy.exclamation, NyanCat().exclamation)
        XCTAssertEqual(proxy.awesomenessLevel, NyanCat().awesomenessLevel)
    }
    
    func testNonImmediateSuperclass() {
        guard let proxy = nyanNyanCat.superProxy(forAncestor: Cat.self) else {
            XCTFail()
            return
        }
        XCTAssertEqual(proxy.says(), Cat().says())
        XCTAssertEqual(proxy.exclamation, Cat().exclamation)
        XCTAssertEqual(proxy.awesomenessLevel, Cat().awesomenessLevel)
    }
}
