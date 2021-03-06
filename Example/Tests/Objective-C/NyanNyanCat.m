//
//  NyanNyanCat.m
//  SuperMessagingProxyTests
//
//  Created by Aleksandr Gusev on 20/05/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

#import "NyanNyanCat.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NyanNyanCat

@synthesize awesomenessLevel = _awesomenessLevel;

- (instancetype)init {
    if (self = [super init]) {
        _awesomenessLevel = NSIntegerMax;
    }
    return self;
}

- (NSString *)exclamation {
    return @"Nyan! Nyan! Nyan!!!";
}

- (NSString *)says {
    return @"Nyan-nyan";
}

- (CatDescriptor)descriptor {
    CatDescriptor descriptor;
    memset(&descriptor, 0, sizeof(descriptor));
    strncpy(descriptor.name, "NyanNyanCat", sizeof("NyanNyanCat"));
    return descriptor;
}

- (NSString *)methodFromALeafClass {
    return @"I am a nyan-nyan-nyan cat!";
}

+ (NSString *)classSays {
    return @"Class nyan-nyan";
}

+ (NSInteger)classAwesomenessLevel {
    return NSIntegerMax - 1;
}

@end

NS_ASSUME_NONNULL_END
