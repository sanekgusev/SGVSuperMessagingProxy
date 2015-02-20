//
//  DerivedFromDerived.m
//  SGVSuperMessagingProxy
//
//  Created by Aleksandr Gusev on 2/20/15.
//  Copyright (c) 2015 Alexander Gusev. All rights reserved.
//

#import "DerivedFromDerived.h"

@implementation DerivedFromDerived

- (NSString *)stringValue {
    NSString *superValue = [super stringValue];
    return @"DerivedFromDerived";
}

- (char)charValue {
    char superValue = [super charValue];
    return '2';
}

- (long long)longLongValue {
    long long superValue = [super longLongValue];
    return 2ll;
}

- (_Complex long double)complexLongDoubleValue {
    _Complex long double superValue = [super complexLongDoubleValue];
    return 2.0;
}

- (SmallStruct)smallStructValue {
    SmallStruct superValue = [super smallStructValue];
    return (SmallStruct){'2'};
}

- (MediumStruct)mediumStructValue {
    MediumStruct superValue = [super mediumStructValue];
    return (MediumStruct){2l};
}

- (MediumLargeStruct)mediumLargeStructValue {
    MediumLargeStruct superValue = [super mediumLargeStructValue];
    return (MediumLargeStruct){{2l, 2l}};
}

- (LargeStruct)largeStructValue {
    LargeStruct superValue = [super largeStructValue];
    return (LargeStruct){{2l, 2l, 2l}};
}

@end
