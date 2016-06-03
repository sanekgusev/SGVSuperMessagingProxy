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

- (nullable instancetype)sgv_super {
    return [SGVSuperMessagingProxy proxyWithObject:self retainsObject:YES];
}

- (nullable instancetype)sgv_superForAncestorClass:(Class)ancestorClass {
    return [SGVSuperMessagingProxy proxyWithObject:self
                                     ancestorClass:ancestorClass
                                     retainsObject:YES];
}

@end

NS_ASSUME_NONNULL_END