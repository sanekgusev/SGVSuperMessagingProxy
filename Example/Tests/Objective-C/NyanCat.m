//
//  NyanCat.m
//  SuperMessagingProxyTests
//
//  Created by Aleksandr Gusev on 20/05/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

#import "NyanCat.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NyanCat

@synthesize awesomenessLevel = _awesomenessLevel;

- (instancetype)init {
    if (self = [super init]) {
        _awesomenessLevel = 10;
    }
    return self;
}

- (NSString *)exclamation {
    return @"Nyan!";
}

- (NSString *)says {
    return @"Nyan";
}

- (CatDescriptor)descriptor {
    CatDescriptor descriptor;
    memset(&descriptor, 0, sizeof(descriptor));
    strncpy(descriptor.name, "NyanCat", sizeof("NyanCat"));
    return descriptor;
}

+ (NSString *)classSays {
    return @"Class Nyan";
}

+ (NSInteger)classAwesomenessLevel {
    return 9;
}

@end

NS_ASSUME_NONNULL_END
