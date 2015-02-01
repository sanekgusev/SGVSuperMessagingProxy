//
//  Fruit.m
//  SGVSuperMessagingProxy
//
//  Created by Aleksandr Gusev on 1/26/15.
//  Copyright (c) 2015 Alexander Gusev. All rights reserved.
//

#import "Fruit.h"

@interface Fruit () {
    NSString *_name;
}

@end

@implementation Fruit

- (instancetype)init {
    if (self = [super init]) {
        _name = @"Fruit";
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _name;
}

- (NSString *)description {
    return [self name];
}

- (NSString *)name {
    return [[self class] name];
}

+ (NSString *)name {
    return @"Fruit";
}

@end
