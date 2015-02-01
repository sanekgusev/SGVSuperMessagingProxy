//
//  Fruit.h
//  SGVSuperMessagingProxy
//
//  Created by Aleksandr Gusev on 1/26/15.
//  Copyright (c) 2015 Alexander Gusev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct FruitStruct {
    CGFloat value;
    CGFloat value2;
    CGFloat value3;
} FruitStruct;

@interface Fruit : NSObject

- (NSString *)name;
+ (NSString *)name;

- (FruitStruct)structValue;
- (CGFloat)floatValue;
- (long double)longDoubleValue;
- (_Complex long double)complexLongDoubleValue;

@end
