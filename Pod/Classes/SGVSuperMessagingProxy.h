//
//  SGVSuperMessagingProxy.h
//  Pods
//
//  Created by Aleksandr Gusev on 1/10/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(Proxy)
@interface SGVSuperMessagingProxy : NSProxy

/// Uses trampolines to objc_msgSendSuper[_stret]
+ (id)proxyWithObject:(id)object
        ancestorClass:(Class __unsafe_unretained)ancestorClass NS_SWIFT_NAME(superFor(_:ancestorClass:));

/// Uses trampolines to objc_msgSendSuper2[_stret]
+ (id)proxyWithObject:(id)object NS_SWIFT_NAME(superFor(_:));

@end

NS_ASSUME_NONNULL_END