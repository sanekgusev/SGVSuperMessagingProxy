//
//  NSObject+SGVSuperMessaging.m
//  Pods
//
//  Created by Aleksandr Gusev on 1/26/15.
//
//

#import "NSObject+SGVSuperMessaging.h"
#import "SGVSuperMessagingProxy.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSObject (SGVSuperMessaging)

- (instancetype)sgv_super {
    return [SGVSuperMessagingProxy proxyWithObject:self];
}

- (instancetype)sgv_superForAncestorClass:(Class __unsafe_unretained)ancestorClass {
    return [SGVSuperMessagingProxy proxyWithObject:self
                                     ancestorClass:ancestorClass];
}

@end

NS_ASSUME_NONNULL_END