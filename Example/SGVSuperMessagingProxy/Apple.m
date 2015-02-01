//
//  Apple.m
//  SGVSuperMessagingProxy
//
//  Created by Aleksandr Gusev on 1/26/15.
//  Copyright (c) 2015 Alexander Gusev. All rights reserved.
//

#import "Apple.h"

@implementation Apple

+ (NSString *)name {
    NSString *superName = [super name];
    return [NSString stringWithFormat:@"%@ — %@", superName, @"Apple"];
}

- (NSString *)name {
    NSString *superName = [super name];
    return [NSString stringWithFormat:@"%@ — %@", superName, @"Apple"];
}

- (FruitStruct)structValue {
    return (FruitStruct){10.0f, 10.0f, 10.0f};
}

- (CGFloat)floatValue {
    return 10.0f;
}

- (long double)longDoubleValue {
    return 10.0;
}

@end
