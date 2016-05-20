//
//  SGVSuperMessagingProxy.h
//  Pods
//
//  Created by Aleksandr Gusev on 1/10/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Super)
/// SGVSuperMessagingProxy: Proxy class for invoking superclass method implementations of proxied object
/// - Warning: Does not retain `object` and expects `object` to be kept alive during it entire lifetime
@interface SGVSuperMessagingProxy : NSProxy

/// Uses trampolines to objc_msgSendSuper[_stret]
+ (_Nullable id)proxyWithObject:(id)object
                  ancestorClass:(Class __unsafe_unretained)ancestorClass NS_SWIFT_NAME(from(_:ancestorClass:));

/// Uses trampolines to objc_msgSendSuper2[_stret]
+ (_Nullable id)proxyWithObject:(id)object NS_SWIFT_NAME(from(_:));

@end

NS_ASSUME_NONNULL_END