//
//  SGVSuperMessagingProxy.h
//  Pods
//
//  Created by Aleksandr Gusev on 1/10/15.
//
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// SGVSuperMessagingProxy: Proxy class for invoking superclass method implementations of proxied object
@interface SGVSuperMessagingProxy : NSProxy

/// Uses trampolines to objc_msgSendSuper[_stret]
+ (nullable id)proxyWithObject:(id __unsafe_unretained)object
                 ancestorClass:(Class)ancestorClass
                 retainsObject:(BOOL)retainsObject;

/// Uses trampolines to objc_msgSendSuper2[_stret]
+ (nullable id)proxyWithObject:(id __unsafe_unretained)object
                 retainsObject:(BOOL)retainsObject;

@end

NS_ASSUME_NONNULL_END