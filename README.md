> *“Some assembly required”*

# SGVSuperMessagingProxy

A ~~downright crazy~~ slightly nontrivial NSProxy subclass for invoking superclass method implementations of any Objective-C object.

## What

A proxy object that allows one to invoke method implementations from any class in the inheritance hierarchy for any Objective-C object.
On creation, the proxy is passed the object and optionally a class in that object's inheritance hierarchy.
Any message send to a proxy will be executed as if it was invoked with a super keyword from inside that object's class declaration.

```objc
  
  Derived *derived = [Derived new];
  id superProxy = [derived sgv_super];
  [superProxy someMethod];

```

## How

The proxy is initialized with a pointer to the original object. It uses the dynamic method resolving mechanism of Objective-C runtime (by implementing `+resolveInstanceMethod:`) to dynamically add implementations for all selectors invoked on the proxy instance. 
These dynamically added implementations are trampoline functions written in assembly that modify original method arguments and then do a tail call to one of `objc_msgSendSuper()`, `objc_msgSendSuper_stret()`, `objc_msgSendSuper2()`, or `objc_msgSendSuper2_stret()` Objective-C runtime functions. 
The modification of the arguments involves substituting the original message receiver (self pointer to the proxy instance) with a pointer to an `objc_super` structure as expected by the `objc_msgSendSuper` functions. The rest of the original method arguments remain unchanged and are passed to `objc_msgSendSuper` verbatim.
The `objc_super` structure containing a pointer to an original object and a class pointer for method implementation lookup is stored as an ivar in the proxy.

The challenges are:
- not to corrupt register state while modifying arguments
- to correctly handle both normal methods and methods returning large/struct values (by using trampolines to `objc_msgSendSuper` and `objc_msgSendSuper_stret`, as appropriate)
- to implement argument substitution for all currently used platforms (arm and arm64 for iOS devices, i386 and x86-64 for various iOS Simulator flavours)

## Why

Just because.

## Usage

To run the example project, run `pod try SGVSuperMessagingProxy`.

## Requirements

iOS 7+. Likely works on previous versions too.

## Installation

SGVSuperMessagingProxy is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "SGVSuperMessagingProxy", "~> 1.0"

## Author

Alexander Gusev  
[@sanekgusev](https://twitter.com/sanekgusev)  
[sanekgusev@gmail.com](mailto:sanekgusev@gmail.com)

## License

SGVSuperMessagingProxy is available under the MIT license. See the LICENSE file for more info.

