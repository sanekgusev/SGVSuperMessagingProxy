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
                                                   MsgSendSuperFunction_MsgSendSuper) alloc] initWithObject:object
            ancestorClass:ancestorClass];
}

+ (id)proxyWithObject:(id __attribute__((nonnull)))object {
    return [[SGVProxySubclassForProxiedObjectClass(object_getClass(object),
                                                   MsgSendSuperFunction_MsgSendSuper2) alloc] initWithObject:object];
}

#pragma mark - Trampolines

#if defined(__arm64__)
    #define SGVNormalTrampoline(trampolineName, msgSendSuperName) \
    __attribute__((__naked__)) \
    static void trampolineName(void) { \
        asm volatile ("add x0, x0, %[value]\n\t" \
                      "b " #msgSendSuperName "\n\t" \
                      :  : [value] "I" (sizeof(Class))); \
    }
#elif defined(__arm__)
    #define SGVNormalTrampoline(trampolineName, msgSendSuperName) \
    __attribute__((__naked__)) \
    static void trampolineName(void) { \
        asm volatile ("add r0, %[value]\n\t" \
                      "b " #msgSendSuperName "\n\t" \
                      :  : [value] "I" (sizeof(Class))); \
    }
#elif defined(__x86_64__)
    #define SGVNormalTrampoline(trampolineName, msgSendSuperName) \
    __attribute__((__naked__)) \
    static void trampolineName(void) { \
        asm volatile ("addq %[value], %%rdi\n\t" \
                      "jmp " #msgSendSuperName "\n\t" \
                      :  : [value] "I" (sizeof(Class))); \
    }
#elif defined(__i386__)
    #define SGVNormalTrampoline(trampolineName, msgSendSuperName) \
    __attribute__((__naked__)) \
    static void trampolineName(void) { \
        asm volatile ("movl 0x4(%%esp), %%ecx\n\t" \
                      "addl %[value], %%ecx\n\t" \
                      "movl %%ecx, 0x4(%%esp)\n\t" \
                      "jmp " #msgSendSuperName "\n\t" \
                      :  : [value] "I" (sizeof(Class))); \
    }
#else
    #error - Unknown arhitecture
#endif

SGVNormalTrampoline(SGVObjcMsgSendSuperTrampoline, _objc_msgSendSuper)
SGVNormalTrampoline(SGVObjcMsgSendSuper2Trampoline, _objc_msgSendSuper2)

#if defined(__arm64__)
    #define SGVStretTrampoline(trampolineName, msgSendSuperName)
#elif defined(__arm__)
    #define SGVStretTrampoline(trampolineName, msgSendSuperName) \
    __attribute__((__naked__)) \
    static void trampolineName(void) { \
        asm volatile ("add r1, %[value]\n\t" \
                      "b " #msgSendSuperName "\n\t" \
                      :  : [value] "I" (sizeof(Class))); \
    }
#elif defined(__x86_64__)
    #define SGVStretTrampoline(trampolineName, msgSendSuperName) \
    __attribute__((__naked__)) \
    static void trampolineName(void) { \
        asm volatile ("addq %[value], %%rsi\n\t" \
                      "jmp " #msgSendSuperName "\n\t" \
                      :  : [value] "I" (sizeof(Class))); \
    }
#elif defined (__i386__)
    #define SGVStretTrampoline(trampolineName, msgSendSuperName) \
    __attribute__((__naked__)) \
    static void trampolineName(void) { \
        asm volatile ("movl 0x8(%%esp), %%ecx\n\t" \
                      "addl %[value], %%ecx\n\t" \
                      "movl %%ecx, 0x8(%%esp)\n\t" \
                      "jmp " #msgSendSuperName "\n\t" \
                      :  : [value] "I" (sizeof(Class))); \
    }
#else
    #error - Unknown arhitecture
#endif

SGVStretTrampoline(SGVObjcMsgSendSuperStretTrampoline, _objc_msgSendSuper_stret);
SGVStretTrampoline(SGVObjcMsgSendSuper2StretTrampoline, _objc_msgSendSuper2_stret);

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

static BOOL SGVAddTrampolineMethod(Class __unsafe_unretained proxySubclass,
                                   Method method,
                                   MsgSendSuperFunction superFunction) {
    SEL selector = method_getName(method);
    const char *typeEncoding = method_getTypeEncoding(method);
    
    DispatchMode dispatchMode = DispatchMode_Normal;
    
#if defined (__arm64__)
    // ARM64 doesn't use stret dispatch at all, yay!
    dispatchMode = DispatchMode_Normal;
#elif defined (__arm__)
    // On arm, stret dispatch is used whenever the re
    dispatchMode = (typeEncoding[0] == _C_STRUCT_B) ? DispatchMode_Stret : DispatchMode_Normal;
#elif defined (__x86_64__) || defined(__i386__)
    NSUInteger returnTypeActualSize = 0;
    NSUInteger returnTypeAlignedSize = 0;
    // NOTE: chokes on __Complex long double
    NSGetSizeAndAlignment(typeEncoding,
                          &returnTypeActualSize,
                          &returnTypeAlignedSize);
    dispatchMode = ((typeEncoding[0] == _C_STRUCT_B) && (returnTypeActualSize > sizeof(void *) * 2)) ? DispatchMode_Stret : DispatchMode_Normal;
#else
    #error - Unknown architecture
#endif
    
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
            NSCAssert(NO, @"invalid dispath mode");
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
            NSLog(@"Adding trampoline override for selector %@",
                  NSStringFromSelector(method_getName(method)));
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
