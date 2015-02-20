//
//  SGVAppDelegate.m
//  SGVSuperMessagingProxy
//
//  Created by CocoaPods on 01/10/2015.
//  Copyright (c) 2014 Alexander Gusev. All rights reserved.
//

#import "SGVAppDelegate.h"
#import "NSObject+SGVSuperMessaging.h"
#import "DerivedFromDerived.h"

@implementation SGVAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_window makeKeyAndVisible];
    
    DerivedFromDerived *derivedFromDerived = [DerivedFromDerived new];
    id superProxy = [derivedFromDerived sgv_superForAncestorClass:[Base class]];
    SmallStruct smallStruct = [superProxy smallStructValue];
    MediumStruct mediumStruct = [superProxy mediumStructValue];
    MediumLargeStruct mediumLargeStruct = [superProxy mediumLargeStructValue];
    LargeStruct largeStruct = [superProxy largeStructValue];
    
    return YES;
}

@end
