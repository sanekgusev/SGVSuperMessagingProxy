//
//  Cat.m
//  SuperMessagingProxyTests
//
//  Created by Aleksandr Gusev on 20/05/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

#import "Cat.h"

NS_ASSUME_NONNULL_BEGIN

@implementation Cat

- (instancetype)init {
    if (self = [super init]) {
        _awesomenessLevel = [Cat awesomenessLevel];
    }
    return self;
}

- (NSString *)exclamation {
    return @"Meouw!";
}

- (NSString *)says {
    return [Cat says];
}

- (CatDescriptor)descriptor {
    CatDescriptor descriptor;
    memset(&descriptor, 0, sizeof(descriptor));
    strncpy(descriptor.name, "Cat", sizeof("Cat"));
    return descriptor;
}

+ (NSString *)says {
    return @"Purr";
}

+ (NSInteger)awesomenessLevel {
    return 5;
}

@end

NS_ASSUME_NONNULL_END
