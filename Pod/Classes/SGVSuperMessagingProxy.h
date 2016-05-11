//
//  SGVSuperMessagingProxy.h
//  Pods
//
//  Created by Aleksandr Gusev on 1/10/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGVSuperMessagingProxy : NSProxy

/// Uses trampolines to objc_msgSendSuper[_stret]
+ (id)proxyWithObject:(id)object
        ancestorClass:(Class __unsafe_unretained)ancestorClass;

/// Uses trampolines to objc_msgSendSuper2[_stret]
+ (id)proxyWithObject:(id)object;

@end

NS_ASSUME_NONNULL_END