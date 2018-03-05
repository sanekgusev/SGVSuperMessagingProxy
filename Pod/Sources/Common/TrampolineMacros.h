//
//  TrampolineMacros.h
//  Pods
//
//  Created by Aleksandr Gusev on 29/05/16.
//
//

#pragma once

#import <sys/types.h>

// Generate function declarations for header files

#define _SGVDeclareTrampolineFuction(trampolineFunction) \
void trampolineFunction(void);

#define SGVDeclareTrampolineFuction(trampolineFunction) \
_SGVDeclareTrampolineFuction(trampolineFunction)

// Generate function definitions for implementation files

#if defined(__arm64__)

#define SGVSelfLocation x0
#define SGVSelfLocationStret x1
#define SGVIvarOffsetObjc 8
#define SGVIvarOffsetSwift 16

#define _SGVDefineTrampolineFuction(trampolineFunction, msgSendSuperFunction, selfLocation, offset) \
__attribute__((__naked__)) \
void trampolineFunction(void) { \
asm volatile ("add " #selfLocation ", " #selfLocation ", #" #offset "\n\t" \
"b " #msgSendSuperFunction "\n\t" \
: : : "x0", "x1"); \
}

#elif defined(__arm__)

#define SGVSelfLocation r0
#define SGVSelfLocationStret r1
#define SGVIvarOffsetObjc 4
#define SGVIvarOffsetSwift 8

#define _SGVDefineTrampolineFuction(trampolineFunction, msgSendSuperFunction, selfLocation, offset) \
__attribute__((__naked__)) \
void trampolineFunction(void) { \
asm volatile ("add " #selfLocation ", #" #offset "\n\t" \
"b " #msgSendSuperFunction "\n\t" \
: : : "r0", "r1"); \
}

#elif defined(__x86_64__)

#define SGVSelfLocation %%rdi
#define SGVSelfLocationStret %%rsi
#define SGVIvarOffsetObjc 8
#define SGVIvarOffsetSwift 16

#define _SGVDefineTrampolineFuction(trampolineFunction, msgSendSuperFunction, selfLocation, offset) \
__attribute__((__naked__)) \
void trampolineFunction(void) { \
asm volatile ("addq $" #offset ", " #selfLocation "\n\t" \
"jmp " #msgSendSuperFunction "\n\t" \
: : : "rsi", "rdi"); \
}

#elif defined(__i386__)

#define SGVSelfLocation 0x4(%%esp)
#define SGVSelfLocationStret 0x8(%%esp)
#define SGVIvarOffsetObjc 4
#define SGVIvarOffsetSwift 8

#define _SGVDefineTrampolineFuction(trampolineFunction, msgSendSuperFunction, selfLocation, offset) \
__attribute__((__naked__)) \
void trampolineFunction(void) { \
asm volatile ("addl $" #offset ", " #selfLocation "\n\t" \
"jmp " #msgSendSuperFunction "\n\t" \
: : : "memory"); \
}

#else
#error - Unknown arhitecture
#endif

#define SGVDefineTrampolineFuction(trampolineFunction, msgSendSuperFunction, selfLocation, offset) \
_SGVDefineTrampolineFuction(trampolineFunction, msgSendSuperFunction, selfLocation, offset)

#define _SGVDefineAddressOfTrampolineFunctionFunction(addressOfFunction, trampolineFunction) \
uintptr_t addressOfFunction(void) { \
return (uintptr_t)&trampolineFunction; \
}

#define SGVDefineAddressOfTrampolineFunctionFunction(addressOfFunction, trampolineFunction) \
_SGVDefineAddressOfTrampolineFunctionFunction(addressOfFunction, trampolineFunction)
