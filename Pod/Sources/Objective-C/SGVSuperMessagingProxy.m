//
//  SGVSuperMessagingProxy.m
//  Pods
//
//  Created by Aleksandr Gusev on 1/10/15.
//
//

#import "SGVSuperMessagingProxy.h"
#import "ObjcTrampolines.h"
#import <objc/message.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MsgSendSuperFunction) {
    MsgSendSuperFunction_MsgSendSuper,
    MsgSendSuperFunction_MsgSendSuper2
};

typedef NS_ENUM(NSInteger, DispatchMode) {
    DispatchMode_Normal,
    DispatchMode_Stret,
};

@interface SGVSuperMessagingProxy () {
    struct objc_super _super;
    id _object;
}

@end

@implementation SGVSuperMessagingProxy

#pragma mark - Public

+ (_Nullable id)proxyWithObject:(id __unsafe_unretained)object
                  ancestorClass:(Class)ancestorClass
                  retainsObject:(BOOL)retainsObject {
    if (object == nil || ancestorClass == nil) {
        return nil;
    }
    Class classOfObject = object_getClass(object);
    BOOL isStrictSubclass = SGVClassIsStrictSubclassOfClass(classOfObject, ancestorClass);
    if (!isStrictSubclass) {
        return nil;
    }
    SGVSuperMessagingProxy *proxy = [SGVUniqueProxySubclassForProxiedObjectClass(classOfObject,
                                                                           MsgSendSuperFunction_MsgSendSuper) alloc];
    proxy->_super.receiver = object;
    proxy->_super.super_class = ancestorClass;
    if (retainsObject) {
        proxy->_object = object;
    }
    return proxy;
}

+ (_Nullable id)proxyWithObject:(id __unsafe_unretained)object
                  retainsObject:(BOOL)retainsObject {
    if (object == nil) {
        return nil;
    }
    Class classOfObject = object_getClass(object);
    BOOL isRootClass = class_getSuperclass(classOfObject) == nil;
    if (isRootClass) {
        return nil;
    }
    
    SGVSuperMessagingProxy *proxy = [SGVUniqueProxySubclassForProxiedObjectClass(classOfObject,
                                                                           MsgSendSuperFunction_MsgSendSuper2) alloc];
    proxy->_super.receiver = object;
    proxy->_super.super_class = classOfObject;
    if (retainsObject) {
        proxy->_object = object;
    }
    return proxy;
}

#pragma mark - Dealloc

- (void)dealloc {
    Class proxySubclass = object_getClass(self);
    Class rootClass = class_getSuperclass(class_getSuperclass(proxySubclass));
    object_setClass(self, rootClass);
    objc_disposeClassPair(proxySubclass);
}

#pragma mark - Key-Value Observing

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

#pragma mark - Resolving

+ (BOOL)resolveInstanceMethod:(SEL)selector {
    Class originalClass;
    MsgSendSuperFunction superFunction;
    if (!SGVGetOriginalObjectClassAndSuperFunctionFromProxySubclass(self,
                                                                    &originalClass,
                                                                    &superFunction)) {
        return NO;
    }
    Class superClass = class_getSuperclass(originalClass);
    if (superClass == nil) {
        return NO;
    }
    Method method = class_getInstanceMethod(superClass, selector);
    if (method == NULL) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"No dynamically dispatched method with selector %@ is available on any of the superclasses of %@",
         NSStringFromSelector(selector), NSStringFromClass(originalClass)];
        return NO;
    }
    
    return SGVAddTrampolineMethod(self, selector, method_getTypeEncoding(method), superFunction);
}

#pragma mark - Private

static BOOL SGVClassIsStrictSubclassOfClass(Class class,
                                            Class possibleSuperclass) {
    Class superclass = class_getSuperclass(class);
    while (superclass != nil) {
        if (superclass == possibleSuperclass) {
            return YES;
        }
        superclass = class_getSuperclass(superclass);
    }
    return NO;
}

static BOOL SGVGetOriginalObjectClassAndSuperFunctionFromProxySubclass(Class class,
                                                                       Class *originalObjectClass,
                                                                       MsgSendSuperFunction *superFunction) {
    NSString *proxySubclassName = NSStringFromClass(class);
    NSArray *components = [proxySubclassName componentsSeparatedByString:@"_"];
    if ([components count] != 3) {
        return NO;
    }
    NSString *originalObjectClassName = [components lastObject];
    if (originalObjectClass) {
        *originalObjectClass = NSClassFromString(originalObjectClassName);
    }
    NSString *superFunctionString = components[1];
    if (superFunction) {
        *superFunction = (MsgSendSuperFunction)[superFunctionString integerValue];
    }
    return YES;
}

static DispatchMode SGVGetDispatchMode(const char * typeEncoding) {
    DispatchMode dispatchMode = DispatchMode_Normal;
    
#if defined (__arm64__)
    // ARM64 doesn't use stret dispatch at all, yay!
#elif defined (__arm__) || defined (__x86_64__) || defined(__i386__)
    NSUInteger returnTypeActualSize = 0;
    NSGetSizeAndAlignment(typeEncoding,
                          &returnTypeActualSize,
                          NULL);
    #if defined (__arm__)
        // On arm, stret dispatch is used whenever the return type
        // does not fit into a single register
        dispatchMode = returnTypeActualSize > sizeof(void *) ? DispatchMode_Stret : DispatchMode_Normal;
    #elif defined (__x86_64__) || defined(__i386__)
        // On i386 and x86-64, stret dispatch is used whenever the return type
        // doesn't fit into two registers
        dispatchMode = returnTypeActualSize > (sizeof(void *) * 2) ? DispatchMode_Stret : DispatchMode_Normal;
    #endif
#else
    #error - Unknown architecture
#endif
    
    return dispatchMode;
}

static BOOL SGVAddTrampolineMethod(Class proxySubclass,
                                   SEL selector,
                                   const char *typeEncoding,
                                   MsgSendSuperFunction superFunction) {
    DispatchMode dispatchMode = SGVGetDispatchMode(typeEncoding);
    
    IMP trampolineIMP = NULL;
    switch (dispatchMode) {
        case DispatchMode_Normal:
            trampolineIMP = (superFunction == MsgSendSuperFunction_MsgSendSuper) ?
                SGVObjcMsgSendSuperTrampolineObjc : SGVObjcMsgSendSuper2TrampolineObjc;
            break;
        case DispatchMode_Stret:
            trampolineIMP = (superFunction == MsgSendSuperFunction_MsgSendSuper) ?
                SGVObjcMsgSendSuperStretTrampolineObjc : SGVObjcMsgSendSuper2StretTrampolineObjc;
            break;
        default:
            NSCAssert(NO, @"invalid dispatch mode");
            return NO;
    }
    
    BOOL methodAdded = class_addMethod(proxySubclass,
                                       selector,
                                       trampolineIMP,
                                       typeEncoding);
    if (!methodAdded) {
        NSLog(@"SGVSuperMessagingProxy has failed to add method for selector %@ to class %@",
              NSStringFromSelector(selector),
              NSStringFromClass(proxySubclass));
    }
    
    return methodAdded;
}

static Class SGVUniqueProxySubclassForProxiedObjectClass(Class class,
                                                         MsgSendSuperFunction superFunction) {
    NSCParameterAssert(class);
    if (class == nil) {
        return nil;
    }
    NSString *UUIDString = [[NSUUID new].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *proxySubclassName = [NSStringFromClass([SGVSuperMessagingProxy class]) stringByAppendingFormat:@"%@_%ld_%@",
                                   UUIDString, (long)superFunction, NSStringFromClass(class)];
    Class proxySubclass = objc_allocateClassPair([SGVSuperMessagingProxy class],
                                                 [proxySubclassName UTF8String],
                                                 0);
    if (proxySubclass) {
        
        // For a thin proxy, NSProxy has quite a lot of stuff implemented,
        // which we obviously don't want.
        // For every subclass of our proxy we will reimplement those methods
        // to use our trampolines instead.
        // Scary things starting with an underscore and memory-management related
        // stuff are kept, though.
        unsigned int outCount = 0;
        
        static NSSet *nonForwardedMethodNames;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            nonForwardedMethodNames = [NSSet setWithArray:@[
                                                            @"zone",
                                                            @"retain",
                                                            @"release",
                                                            @"autorelease",
                                                            @"retainCount",
                                                            @"dealloc",
                                                            @"finalize",
                                                            @"retainWeakReference",
                                                            @"allowsWeakReference",
                                                            ]];
        });
        
        Method *methods = class_copyMethodList([NSProxy class], &outCount);
        for (int i = 0; i < outCount; i++) {
            Method method = methods[i];
            SEL selector = method_getName(method);
            NSString *selectorName = NSStringFromSelector(selector);
            if ([selectorName rangeOfString:@"_"].location == 0 ||
                [nonForwardedMethodNames containsObject:selectorName]) {
                continue;
            }
            SGVAddTrampolineMethod(proxySubclass,
                                   selector,
                                   method_getTypeEncoding(method),
                                   superFunction);
        }
        free(methods);
        
        objc_registerClassPair(proxySubclass);
        return proxySubclass;
    }
    return nil;
}

@end

NS_ASSUME_NONNULL_END
