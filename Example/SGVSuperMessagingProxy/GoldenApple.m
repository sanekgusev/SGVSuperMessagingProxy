//
//  GoldenApple.m
//  SGVSuperMessagingProxy
//
//  Created by Aleksandr Gusev on 1/26/15.
//  Copyright (c) 2015 Alexander Gusev. All rights reserved.
//

#import "GoldenApple.h"

@implementation GoldenApple

+ (NSString *)name {
    NSString *superName = [super name];
    return [NSString stringWithFormat:@"%@ — %@", superName, @"Golden"];
}

@end
