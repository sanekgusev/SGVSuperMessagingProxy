//
//  Base.h
//  SGVSuperMessagingProxy
//
//  Created by Aleksandr Gusev on 2/20/15.
//  Copyright (c) 2015 Alexander Gusev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct __attribute__ ((__packed__)) SmallStruct {
    char character;
} SmallStruct;

typedef struct MediumStruct {
    intptr_t longValue;
} MediumStruct;

typedef struct MediumLargeStruct {
    intptr_t array[2];
} MediumLargeStruct;

typedef struct LargeStruct {
    intptr_t array[3];
} LargeStruct;

@interface Base : NSObject

- (NSString *)stringValue;
- (char)charValue;
- (long long)longLongValue;
- (_Complex long double)complexLongDoubleValue;
- (SmallStruct)smallStructValue;
- (MediumStruct)mediumStructValue;
- (MediumLargeStruct)mediumLargeStructValue;
- (LargeStruct)largeStructValue;

@end
