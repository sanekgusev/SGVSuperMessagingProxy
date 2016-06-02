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
    var objcNyanNyanCat = ObjcNyanNyanCat()
    
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
    
    func testImmediateSuperclassObjc() {
        guard let proxy = objcNyanNyanCat.superProxy else {
            XCTFail()
            return
        }
        XCTAssertEqual(proxy.says(), ObjcNyanCat().says())
        XCTAssertEqual(proxy.exclamation, ObjcNyanCat().exclamation)
        XCTAssertEqual(proxy.awesomenessLevel, ObjcNyanCat().awesomenessLevel)
    }
    
    func testNonImmediateSuperclassObjc() {
        guard let proxy = objcNyanNyanCat.superProxy(forAncestor: ObjcCat.self) else {
            XCTFail()
            return
        }
        XCTAssertEqual(proxy.says(), ObjcCat().says())
        XCTAssertEqual(proxy.exclamation, ObjcCat().exclamation)
        XCTAssertEqual(proxy.awesomenessLevel, ObjcCat().awesomenessLevel)
    }
}
