//
//  Trampolines.c
//  Pods
//
//  Created by Aleksandr Gusev on 25/05/16.
//
//

#include "ObjcTrampolines.h"

SGVDefineTrampolineFuction(SGVObjcMsgSendSuperTrampolineObjc, _objc_msgSendSuper, SGVSelfLocation, 8)
SGVDefineTrampolineFuction(SGVObjcMsgSendSuper2TrampolineObjc, _objc_msgSendSuper2, SGVSelfLocation, 8)

#if !defined(__arm64__)
SGVDefineTrampolineFuction(SGVObjcMsgSendSuperStretTrampolineObjc, _objc_msgSendSuper_stret, SGVSelfLocationStret, 8)
SGVDefineTrampolineFuction(SGVObjcMsgSendSuper2StretTrampolineObjc, _objc_msgSendSuper2_stret, SGVSelfLocationStret, 8)
#endif