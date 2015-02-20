//
//  SGVSuperMessagingProxy.m
//  Pods
//
//  Created by Aleksandr Gusev on 1/10/15.
//
//

#import "SGVSuperMessagingProxy.h"
#import <objc/message.h>
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, MsgSendSuperFunction) {
    MsgSendSuperFunction_MsgSendSuper,
    MsgSendSuperFunction_MsgSendSuper2
};

typedef NS_ENUM(NSInteger, DispatchMode) {
    DispatchMode_Normal,
    DispatchMode_Stret,
};

static ptrdiff_t SGVSuperMessagingProxySuperIvarOffset = 0;

@interface SGVSuperMessagingProxy () {
    struct objc_super _super;
}

@end

@implementation SGVSuperMessagingProxy

#pragma mark - Public

+ (id)proxyWithObject:(id)object
        ancestorClass:(Class __unsafe_unretained)ancestorClass {
    SGVSuperMessagingProxy *proxy = [SGVProxySubclassForProxiedObjectClass(object_getClass(object),
                                                                           MsgSendSuperFunction_MsgSendSuper) alloc];
    proxy->_super.receiver = object;
    proxy->_super.super_class = ancestorClass;
    return proxy;
}

+ (id)proxyWithObject:(id __attribute__((nonnull)))object {
    SGVSuperMessagingProxy *proxy = [SGVProxySubclassForProxiedObjectClass(object_getClass(object),
                                                                           MsgSendSuperFunction_MsgSendSuper2) alloc];
    proxy->_super.receiver = object;
    proxy->_super.super_class = object_getClass(object);
    return proxy;
}

#pragma mark - Key-Value Observing

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

#pragma mark - Trampolines

#if defined(__arm64__)

    #define SGVSelfLocation x0
    #define SGVSelfLocationStret x1

    #define _SGVDeclareTrampolineFuction(trampolineName, msgSendSuperName, selfLocation) \
    __attribute__((__naked__)) \
    static void trampolineName(void) { \
        asm volatile ("add " #selfLocation ", " #selfLocation ", %[value]\n\t" \
                      "b " #msgSendSuperName "\n\t" \
                      :  : [value] "I" (sizeof(Class))); \
    }

#elif defined(__arm__)

    #define SGVSelfLocation r0
    #define SGVSelfLocationStret r1

    #define _SGVDeclareTrampolineFuction(trampolineName, msgSendSuperName, selfLocation) \
    __attribute__((__naked__)) \
    static void trampolineName(void) { \
        asm volatile ("add " #selfLocation ", %[value]\n\t" \
                      "b " #msgSendSuperName "\n\t" \
                      :  : [value] "I" (sizeof(Class))); \
    }

#elif defined(__x86_64__)

    #define SGVSelfLocation %%rdi
    #define SGVSelfLocationStret %%rsi

    #define _SGVDeclareTrampolineFuction(trampolineName, msgSendSuperName, selfLocation) \
    __attribute__((__naked__)) \
    static void trampolineName(void) { \
        asm volatile ("addq %[value], " #selfLocation "\n\t" \
                      "jmp " #msgSendSuperName "\n\t" \
                      :  : [value] "I" (sizeof(Class))); \
    }

#elif defined(__i386__)

    #define SGVSelfLocation 0x4(%%esp)
    #define SGVSelfLocationStret 0x8(%%esp)

    #define _SGVDeclareTrampolineFuction(trampolineName, msgSendSuperName, selfLocation) \
    __attribute__((__naked__)) \
    static void trampolineName(void) { \
        asm volatile ("movl " #selfLocation ", %%ecx\n\t" \
                      "addl %[value], %%ecx\n\t" \
                      "movl %%ecx, " #selfLocation "\n\t" \
                      "jmp " #msgSendSuperName "\n\t" \
                      :  : [value] "I" (sizeof(Class))); \
    }

#else
    #error - Unknown arhitecture
#endif

#define SGVDeclareTrampolineFuction(trampolineName, msgSendSuperName, selfLocation) _SGVDeclareTrampolineFuction(trampolineName, msgSendSuperName, selfLocation)

SGVDeclareTrampolineFuction(SGVObjcMsgSendSuperTrampoline, _objc_msgSendSuper, SGVSelfLocation)
SGVDeclareTrampolineFuction(SGVObjcMsgSendSuper2Trampoline, _objc_msgSendSuper2, SGVSelfLocation)
#if defined(__arm64__)
    #define SGVObjcMsgSendSuperStretTrampoline NULL
    #define SGVObjcMsgSendSuper2StretTrampoline NULL
#else
    SGVDeclareTrampolineFuction(SGVObjcMsgSendSuperStretTrampoline, _objc_msgSendSuper_stret, SGVSelfLocationStret)
    SGVDeclareTrampolineFuction(SGVObjcMsgSendSuper2StretTrampoline, _objc_msgSendSuper2_stret, SGVSelfLocationStret)
#endif

#pragma mark - Resolving

+ (BOOL)resolveInstanceMethod:(SEL)selector {
    Class __unsafe_unretained originalClass;
    MsgSendSuperFunction superFunction;
    if (!SGVGetOriginalObjectClassAndSuperFunctionFromProxySubclass(self,
                                                           &originalClass,
                                                           &superFunction)) {
        return NO;
    }
    Method method = class_getInstanceMethod(originalClass, selector);
    if (method == NULL) {
        return NO;
    }
    
    return SGVAddTrampolineMethod(self, method, superFunction);
}

#pragma mark - Private

static BOOL SGVGetOriginalObjectClassAndSuperFunctionFromProxySubclass(Class __unsafe_unretained class,
                                                                       Class __unsafe_unretained *originalObjectClass,
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

static BOOL SGVAddTrampolineMethod(Class __unsafe_unretained proxySubclass,
                                   Method method,
                                   MsgSendSuperFunction superFunction) {
    const char *typeEncoding = method_getTypeEncoding(method);
    
    DispatchMode dispatchMode = SGVGetDispatchMode(typeEncoding);
    
    IMP trampolineIMP = NULL;
    switch (dispatchMode) {
        case DispatchMode_Normal:
            trampolineIMP = (superFunction == MsgSendSuperFunction_MsgSendSuper) ?
                SGVObjcMsgSendSuperTrampoline : SGVObjcMsgSendSuper2Trampoline;
            break;
        case DispatchMode_Stret:
            trampolineIMP = (superFunction == MsgSendSuperFunction_MsgSendSuper) ?
                SGVObjcMsgSendSuperStretTrampoline : SGVObjcMsgSendSuper2StretTrampoline;
            break;
        default:
            NSCAssert(NO, @"invalid dispatch mode");
            return NO;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SGVSuperMessagingProxySuperIvarOffset = ivar_getOffset(class_getInstanceVariable([SGVSuperMessagingProxy class],
                                                                                         "_super"));
    });
    
    SEL selector = method_getName(method);
    
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

static Class SGVProxySubclassForProxiedObjectClass(Class __unsafe_unretained class,
                                                   MsgSendSuperFunction superFunction) {
    NSCParameterAssert(class);
    if (!class) {
        return nil;
    }
    NSString *proxySubclassName = [NSStringFromClass([SGVSuperMessagingProxy class]) stringByAppendingFormat:@"_%ld_%@",
                                   (long)superFunction, NSStringFromClass(class)];
    Class __unsafe_unretained proxySubclass = objc_allocateClassPair([SGVSuperMessagingProxy class],
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
            NSString *selectorName = NSStringFromSelector(method_getName(method));
            if ([selectorName rangeOfString:@"_"].location == 0 ||
                [nonForwardedMethodNames containsObject:selectorName]) {
                continue;
            }
            SGVAddTrampolineMethod(proxySubclass,
                                   method,
                                   superFunction);
        }
        free(methods);
        
        objc_registerClassPair(proxySubclass);
        return proxySubclass;
    }
    return objc_lookUpClass([proxySubclassName UTF8String]);
}

@end
