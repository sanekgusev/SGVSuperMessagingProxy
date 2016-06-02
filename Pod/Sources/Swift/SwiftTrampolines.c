//
//  SwiftTrampolines.c
//  Pods
//
//  Created by Aleksandr Gusev on 29/05/16.
//
//

#include "SwiftTrampolines.h"

SGVDefineTrampolineFuction(SGVObjcMsgSendSuperTrampolineSwift, _objc_msgSendSuper, SGVSelfLocation, 16)
SGVDefineTrampolineFuction(SGVObjcMsgSendSuper2TrampolineSwift, _objc_msgSendSuper2, SGVSelfLocation, 16)

#if !defined(__arm64__)
SGVDefineTrampolineFuction(SGVObjcMsgSendSuperStretTrampolineSwift, _objc_msgSendSuper_stret, SGVSelfLocationStret, 16)
SGVDefineTrampolineFuction(SGVObjcMsgSendSuper2StretTrampolineSwift, _objc_msgSendSuper2_stret, SGVSelfLocationStret, 16)
#endif
