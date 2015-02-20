//
//  Base.m
//  SGVSuperMessagingProxy
//
//  Created by Aleksandr Gusev on 2/20/15.
//  Copyright (c) 2015 Alexander Gusev. All rights reserved.
//

#import "Base.h"

@implementation Base

- (NSString *)stringValue {
    return @"Base";
}

- (char)charValue {
    return '0';
}

- (long long)longLongValue {
    return 0ll;
}

- (_Complex long double)complexLongDoubleValue {
    return 0.0;
}

- (SmallStruct)smallStructValue {
    return (SmallStruct){'0'};
}

- (MediumStruct)mediumStructValue {
    return (MediumStruct){0l};
}

- (MediumLargeStruct)mediumLargeStructValue {
    return (MediumLargeStruct){{0l, 0l}};
}

- (LargeStruct)largeStructValue {
    return (LargeStruct){{0l, 0l, 0l}};
}

@end
