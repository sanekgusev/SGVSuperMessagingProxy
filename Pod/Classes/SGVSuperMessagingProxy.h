//
//  SGVSuperMessagingProxy.h
//  Pods
//
//  Created by Aleksandr Gusev on 1/10/15.
//
//

#import <Foundation/Foundation.h>

@interface SGVSuperMessagingProxy : NSProxy

/// Uses trampolines to objc_msgSendSuper[_stret]
+ (id)proxyWithObject:(id __attribute__((nonnull)))object
        ancestorClass:(Class __unsafe_unretained __attribute__((nonnull)))ancestorClass;

/// Uses trampolines to objc_msgSendSuper2[_stret]
+ (id)proxyWithObject:(id __attribute__((nonnull)))object;

@end
