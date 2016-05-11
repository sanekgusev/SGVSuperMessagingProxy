//
//  NSObject+SGVSuperMessaging.h
//  Pods
//
//  Created by Aleksandr Gusev on 1/26/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SGVSuperMessaging)

- (instancetype)sgv_super;
- (instancetype)sgv_superForAncestorClass:(Class __unsafe_unretained)ancestorClass;

@end

NS_ASSUME_NONNULL_END