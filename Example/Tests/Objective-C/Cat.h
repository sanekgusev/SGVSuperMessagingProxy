//
//  Cat.h
//  SuperMessagingProxyTests
//
//  Created by Aleksandr Gusev on 20/05/16.
//  Copyright © 2016 Alexander Gusev. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef struct CatDescriptor {
    char name[256];
} CatDescriptor;

@interface Cat : NSObject

@property (nonatomic, readonly) NSString *exclamation;
@property (nonatomic, assign) NSInteger awesomenessLevel;
@property (nonatomic, readonly) CatDescriptor descriptor;

- (NSString *)says;
+ (NSString *)classSays;
+ (NSInteger)classAwesomenessLevel;

- (NSString *)baseClassMethod;

@end

NS_ASSUME_NONNULL_END
