//
//  NSObject+SGVSuperMessaging.h
//  Pods
//
//  Created by Aleksandr Gusev on 1/26/15.
//
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SGVSuperMessaging)

- (nullable instancetype)sgv_super;
- (nullable instancetype)sgv_superForAncestorClass:(Class)ancestorClass;

@end

NS_ASSUME_NONNULL_END