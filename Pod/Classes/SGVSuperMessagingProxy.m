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

typedef NS_ENUM(NSInteger, Mode) {
    Mode_MsgSendSuper,
    Mode_MsgSendSuper2
};

@interface SGVSuperMessagingProxy () {
    struct objc_super _super;
}

@end

@implementation SGVSuperMessagingProxy

#pragma mark - Init/dealloc

- (instancetype)initWithObject:(id)object
                 ancestorClass:(Class __unsafe_unretained)ancestorClass {
    NSCParameterAssert(object);
    NSCParameterAssert(ancestorClass);
    if (!object || !ancestorClass) {
        return nil;
    }
    _super.receiver = object;
    _super.super_class = ancestorClass;
    
    return self;
}

- (instancetype)initWithObject:(id)object {
    NSCParameterAssert(object);
    if (!object) {
        return nil;
    }
    _super.receiver = object;
    _super.super_class = object_getClass(object);
    
    return self;
}

#pragma mark - Public

+ (id)proxyWithObject:(id)object
        ancestorClass:(Class __unsafe_unretained)ancestorClass {
    return [[SGVProxySubclassForProxiedObjectClass(object_getClass(object),
                                                   Mode_MsgSendSuper) alloc] initWithObject:object
            ancestorClass:ancestorClass];
}

+ (id)proxyWithObject:(id __attribute__((nonnull)))object {
    return [[SGVProxySubclassForProxiedObjectClass(object_getClass(object),
                                                   Mode_MsgSendSuper2) alloc] initWithObject:object];
}

#pragma mark - Trampolines

__attribute__((__naked__))
static void SGVObjcMsgSendSuperTrampoline(void) {
    // Ideally, one would get the ivar offset from runtime like this:
//    ptrdiff_t superOffset = ivar_getOffset(class_getInstanceVariable(object_getClass(self),
//                                                                     "_super"));
    // For now, we'll stick with adding the size of isa to the original proxy
    // instance  pointer to get to our objc_super struct
#if defined(__arm64__)
    asm volatile ("add x0, x0, %[value]\n\t"
                  "b _objc_msgSendSuper\n\t"
                  :  : [value] "I" (sizeof(Class)));
#elif defined(__arm__)
    asm volatile ("add r0, %[value]\n\t"
                  "b _objc_msgSendSuper\n\t"
                  :  : [value] "I" (sizeof(Class)));
#elif defined(__x86_64__)
    asm volatile ("addq %[value], %%rdi\n\t"
                  "jmp _objc_msgSendSuper\n\t"
                  :  : [value] "I" (sizeof(Class)));
#elif
#pragma error - Unknown arhitecture
#endif
}

#if defined(__arm__) || defined(__x86_64__)
__attribute__((__naked__))
static void SGVObjcMsgSendSuperStretTrampoline(void) {
#if defined(__arm__)
    asm volatile ("add r1, %[value]\n\t"
                  "b _objc_msgSendSuper_stret\n\t"
                  :  : [value] "I" (sizeof(Class)));
#elif defined(__x86_64__)
    asm volatile ("addq %[value], %%rsi\n\t"
                  "jmp _objc_msgSendSuper_stret\n\t"
                  :  : [value] "I" (sizeof(Class)));
#endif
}
#endif

__attribute__((__naked__))
static void SGVObjcMsgSendSuper2Trampoline(void) {
#if defined(__arm64__)
    asm volatile ("add x0, x0, %[value]\n\t"
                  "b _objc_msgSendSuper2\n\t"
                  :  : [value] "I" (sizeof(Class)));
#elif defined(__arm__)
    asm volatile ("add r0, %[value]\n\t"
                  "b _objc_msgSendSuper2\n\t"
                  :  : [value] "I" (sizeof(Class)));
#elif defined(__x86_64__)
    asm volatile ("addq %[value], %%rdi\n\t"
                  "jmp _objc_msgSendSuper2\n\t"
                  :  : [value] "I" (sizeof(Class)));
#elif
#pragma error - Unknown arhitecture
#endif
}

#if defined(__arm__) || defined(__x86_64__)
__attribute__((__naked__))
static void SGVObjcMsgSendSuper2StretTrampoline(void) {
#if defined(__arm__)
    asm volatile ("add r1, %[value]\n\t"
                  "b _objc_msgSendSuper2_stret\n\t"
                  :  : [value] "I" (sizeof(Class)));
#elif defined(__x86_64__)
    asm volatile ("addq %[value], %%rsi\n\t"
                  "jmp _objc_msgSendSuper2_stret\n\t"
                  :  : [value] "I" (sizeof(Class)));
#endif
}
#endif

#pragma mark - Resolving

+ (BOOL)resolveInstanceMethod:(SEL)selector {
    Class __unsafe_unretained originalClass;
    Mode messagingMode;
    if (!SGVGetOriginalObjectClassAndModeFromProxySubclass(self,
                                                           &originalClass,
                                                           &messagingMode)) {
        return NO;
    }
    Method method = class_getInstanceMethod(originalClass, selector);
    if (method == NULL) {
        return NO;
    }
    
    return SGVAddTrampolineMethod(self, method, messagingMode);
}

#pragma mark - Private

static BOOL SGVGetOriginalObjectClassAndModeFromProxySubclass(Class __unsafe_unretained class,
                                                              Class __unsafe_unretained *originalObjectClass,
                                                              Mode *mode) {
    NSString *proxySubclassName = NSStringFromClass(class);
    NSArray *components = [proxySubclassName componentsSeparatedByString:@"_"];
    if ([components count] != 3) {
        return NO;
    }
    NSString *originalObjectClassName = [components lastObject];
    if (originalObjectClass) {
        *originalObjectClass = NSClassFromString(originalObjectClassName);
    }
    NSString *modeString = components[1];
    if (mode) {
        *mode = (Mode)[modeString integerValue];
    }
    return YES;
}

static BOOL SGVAddTrampolineMethod(Class __unsafe_unretained proxySubclass,
                                   Method method,
                                   Mode messagingMode) {
    SEL selector = method_getName(method);
    const char *typeEncoding = method_getTypeEncoding(method);
    
    BOOL shouldUseStretDispatch = NO;
    
#if defined (__x86_64__) || defined(__arm__)
    NSUInteger returnTypeActualSize = 0;
    NSUInteger returnTypeAlignedSize = 0;
    NSGetSizeAndAlignment(typeEncoding,
                          &returnTypeActualSize,
                          &returnTypeAlignedSize);
    // I made this up, I have no clue (yet) when _exactly_ stret dispatch is used
    shouldUseStretDispatch = returnTypeAlignedSize > sizeof(void *);
#endif
    
    IMP trampolineIMP = NULL;
    switch (messagingMode) {
        case Mode_MsgSendSuper:
            trampolineIMP = shouldUseStretDispatch ? SGVObjcMsgSendSuperStretTrampoline : SGVObjcMsgSendSuperTrampoline;
            break;
        case Mode_MsgSendSuper2:
            trampolineIMP = shouldUseStretDispatch ? SGVObjcMsgSendSuper2StretTrampoline : SGVObjcMsgSendSuper2Trampoline;
            break;
        default:
            NSCAssert(NO, @"unknown mode");
            break;
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

static Class SGVProxySubclassForProxiedObjectClass(Class __unsafe_unretained class,
                                                   Mode mode) {
    NSCParameterAssert(class);
    if (!class) {
        return nil;
    }
    NSString *proxySubclassName = [NSStringFromClass([SGVSuperMessagingProxy class]) stringByAppendingFormat:@"_%ld_%@",
                                   mode, NSStringFromClass(class)];
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
            NSLog(@"Adding trampoline override for selector %@",
                  NSStringFromSelector(method_getName(method)));
            SGVAddTrampolineMethod(proxySubclass,
                                   method,
                                   mode);
        }
        free(methods);
        
        objc_registerClassPair(proxySubclass);
        return proxySubclass;
    }
    return objc_lookUpClass([proxySubclassName UTF8String]);
}

@end
