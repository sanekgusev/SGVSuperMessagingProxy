//
//  Derived.m
//  SGVSuperMessagingProxy
//
//  Created by Aleksandr Gusev on 2/20/15.
//  Copyright (c) 2015 Alexander Gusev. All rights reserved.
//

#import "Derived.h"

@implementation Derived

- (NSString *)stringValue {
    return @"Derived";
}

- (char)charValue {
    return '1';
}

- (long long)longLongValue {
    return 1ll;
}

- (_Complex long double)complexLongDoubleValue {
    return 1.0;
}

- (SmallStruct)smallStructValue {
    return (SmallStruct){'1'};
}

- (MediumStruct)mediumStructValue {
    return (MediumStruct){1l};
}

- (MediumLargeStruct)mediumLargeStructValue {
    return (MediumLargeStruct){{1l, 1l}};
}

- (LargeStruct)largeStructValue {
    return (LargeStruct){{1l, 1l, 1l}};
}

@end
