//
//  NSObject+SGVSuperMessaging.h
//  Pods
//
//  Created by Aleksandr Gusev on 1/26/15.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (SGVSuperMessaging)

- (instancetype)sgv_super;
- (instancetype)sgv_superForAncestorClass:(Class __unsafe_unretained __attribute__((nonnull)))ancestorClass;

@end
