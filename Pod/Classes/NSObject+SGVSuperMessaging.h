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

- (_Nullable instancetype)sgv_super;
- (_Nullable instancetype)sgv_superForAncestorClass:(Class)ancestorClass;

@end

NS_ASSUME_NONNULL_END