> *“Some assembly required”*

# SGVSuperMessagingProxy

An `NSProxy`/`SwiftObject` subclass for invoking superclass method implementations of any Objective-C object. Also works with `dynamic` methods on Swift objects.

## What

A proxy object that allows one to invoke method implementations from any class higher in the inheritance hierarchy for any dynamically dispatched method.  
On creation, the proxy is passed the object and optionally a class in that object's inheritance hierarchy.  
Any message sent to the proxy will be executed as if it was invoked with a super keyword from inside that object's class declaration.

Objective-C example:

```objc
  
@interface Cat : NSObject

@property (nonatomic, readonly) NSString *exclamation;

@end

@implementation Cat

- (NSString *)exclamation {
    return @"Meouw!";
}

@end

@interface NyanCat : Cat

@end

@implementation NyanCat

- (NSString *)exclamation {
    return @"Nyan!";
}

@end

NyanCat *cat = [NyanCat new];
NSLog(@"%@", [cat exclamation]); // -> Nyan!
NSLog(@"%@", [[cat sgv_super] exclamation]); // -> Meouw!

```

Swift example:

```swift

import Foundation

class Cat {
    dynamic func says() -> String {
        return "Purr"
    }
}

class NyanCat: Cat {
    dynamic override func says() -> String {
        return "Nyan"
    }
}

class NyanNyanCat: NyanCat {
    dynamic override func says() -> String {
        return "Nyan-nyan"
    }
}

extension Cat: SuperMessageable {}

let nyanNyanCat = NyanNyanCat()
print(nyanNyanCat.says()) // -> Nyan-nyan
let catProxy = nyanNyanCat.superProxy(forAncestor: Cat.self)!
print(catProxy) // -> Purr

```

## How

The proxy is initialized with a pointer to the original object, which can be optionally retained. It uses the dynamic method resolving mechanism of Objective-C runtime (by implementing `+resolveInstanceMethod:`) to dynamically add implementations for all selectors invoked on the proxy instance.  
These dynamically added implementations are trampoline functions written in assembly that modify original method arguments and then do a tail call to one of `objc_msgSendSuper()`, `objc_msgSendSuper_stret()`, `objc_msgSendSuper2()`, or `objc_msgSendSuper2_stret()` Objective-C runtime functions.  
The modification of the arguments involves substituting the original message receiver (self pointer to the proxy instance) with a pointer to an `objc_super` structure as expected by the `objc_msgSendSuper` functions. The rest of the original method arguments remain unchanged and are passed to `objc_msgSendSuper` verbatim.  
The `objc_super` structure contains a pointer to the original object and a class pointer for method implementation lookup. It is stored as an ivar in the proxy.  

Points of interest:
- preserving register state while modifying arguments in inline assembly
- proper handling of both normal methods and methods returning large/struct values (by using trampolines to `objc_msgSendSuper` and `objc_msgSendSuper_stret` as appropriate)
- funcation argument modification for all currently used platforms (arm and arm64 for iOS devices, i386 and x86-64 for various iOS Simulator flavors)
- Swift support

## Why

Just because.

## Usage

For more Objective-C and Swift examples, one can quickly install and run the unit tests project using `pod try SGVSuperMessagingProxy`. 

## Supported platforms:

- iOS: 7.0+
- OSX: 10.8+, swift 10.9+
- watchOS: 1.0+
- tvOS: 9.0+

## Installation

SGVSuperMessagingProxy is available through [CocoaPods](http://cocoapods.org) and contains separate Objective-C and Swift subspect. Swift subspec is the default.  
For Swift version of the pod add

    pod "SGVSuperMessagingProxy", "~> 2.0"

to the Podfile.  
For Objective-C version, add

    pod "SGVSuperMessagingProxy/Objective-C", "~> 2.0"

to the Podfile.

## Author

Aleksandr Gusev  
[@sanekgusev](https://twitter.com/sanekgusev)  
[sanekgusev@gmail.com](mailto:sanekgusev@gmail.com)

## License

SGVSuperMessagingProxy is available under the MIT license. See the LICENSE file for more info.

