//
//  SGVSuperMessagingProxyTests.m
//  SuperMessagingProxyTests
//
//  Created by Aleksandr Gusev on 20/05/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

@import XCTest;
@import SGVSuperMessagingProxy;

#import "NyanNyanCat.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGVSuperMessagingProxyTests : XCTestCase

@property (nonatomic, strong) NyanNyanCat *nyanNyanCat;

@end

@implementation SGVSuperMessagingProxyTests

- (void)setUp {
    [super setUp];
    self.nyanNyanCat = [NyanNyanCat new];
}

- (void)testSuccessfulProxyCreationFromValidClass {
    XCTAssertNotNil([self.nyanNyanCat sgv_super]);
}

- (void)testFailedProxyCreationFromRootClass {
    XCTAssertNil([[NSObject new] sgv_super]);
    XCTAssertNil([SGVSuperMessagingProxy proxyWithObject:[NSProxy alloc] retainsObject:YES]);
}

- (void)testFailedProxyCreationFromNotAnAncestorClass {
    XCTAssertNil([self.nyanNyanCat sgv_superForAncestorClass:[NyanNyanCat class]]);
}

- (void)testImmediateSuperclass {
    NyanNyanCat *proxy = [self.nyanNyanCat sgv_super];
    if (proxy == nil) {
        XCTFail();
        return;
    }
    XCTAssertEqualObjects([proxy says], [[NyanCat new] says]);
    XCTAssertEqualObjects(proxy.exclamation, [NyanCat new].exclamation);
    XCTAssertEqual(proxy.awesomenessLevel, [NyanCat new].awesomenessLevel);
    XCTAssert(strcmp(proxy.descriptor.name, [NyanCat new].descriptor.name) == 0);
}

- (void)testNonImmediateSuperclass {
    NyanNyanCat *proxy = [self.nyanNyanCat sgv_superForAncestorClass:[Cat class]];
    if (proxy == nil) {
        XCTFail();
        return;
    }
    XCTAssertEqualObjects([proxy says], [[Cat new] says]);
    XCTAssertEqualObjects(proxy.exclamation, [Cat new].exclamation);
    XCTAssertEqual(proxy.awesomenessLevel, [Cat new].awesomenessLevel);
    XCTAssert(strcmp(proxy.descriptor.name, [Cat new].descriptor.name) == 0);
}

- (void)testCallingMethodFromNotImmediateSuperclass {
    NyanCat* proxy = self.nyanNyanCat.sgv_super;
    if (proxy == nil) {
        XCTFail();
        return;
    }
    XCTAssertEqual([proxy baseClassMethod], [[Cat new] baseClassMethod]);
}

- (void)testCallingMethodNotInSuperclass {
    NyanNyanCat *proxy = self.nyanNyanCat.sgv_super;
    if (proxy == nil) {
        XCTFail();
        return;
    }
    XCTAssertThrows([proxy methodFromALeafClass]);
}

- (void)testClassMethodsOfImmediateSuperclass {
    Class proxy = [NyanNyanCat sgv_super];
    if (proxy == nil) {
        XCTFail();
        return;
    }
    XCTAssertEqualObjects([proxy says], [NyanCat says]);
    XCTAssertEqual([proxy awesomenessLevel], [NyanCat awesomenessLevel]);
}

- (void)testClassMethodsOfNonImmediateSuperclass {
    Class proxy = [NyanNyanCat sgv_superForAncestorClass:object_getClass([Cat class])];
    if (proxy == nil) {
        XCTFail();
        return;
    }
    XCTAssertEqualObjects([proxy says], [Cat says]);
    XCTAssertEqual([proxy awesomenessLevel], [Cat awesomenessLevel]);
}

@end

NS_ASSUME_NONNULL_END
