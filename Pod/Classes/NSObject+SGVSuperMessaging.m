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

- (_Nullable instancetype)sgv_super {
    return [SGVSuperMessagingProxy proxyWithObject:self];
}

- (_Nullable instancetype)sgv_superForAncestorClass:(Class)ancestorClass {
    return [SGVSuperMessagingProxy proxyWithObject:self
                                     ancestorClass:ancestorClass];
}

@end

NS_ASSUME_NONNULL_END