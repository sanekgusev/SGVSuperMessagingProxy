//
//  Trampolines.c
//  Pods
//
//  Created by Aleksandr Gusev on 25/05/16.
//
//

#include "ObjcTrampolines.h"

SGVDefineTrampolineFuction(SGVObjcMsgSendSuperTrampolineObjc, _objc_msgSendSuper, SGVSelfLocation, SGVIvarOffsetObjc)
SGVDefineTrampolineFuction(SGVObjcMsgSendSuper2TrampolineObjc, _objc_msgSendSuper2, SGVSelfLocation, SGVIvarOffsetObjc)

#if !defined(__arm64__)
SGVDefineTrampolineFuction(SGVObjcMsgSendSuperStretTrampolineObjc, _objc_msgSendSuper_stret, SGVSelfLocationStret, SGVIvarOffsetObjc)
SGVDefineTrampolineFuction(SGVObjcMsgSendSuper2StretTrampolineObjc, _objc_msgSendSuper2_stret, SGVSelfLocationStret, SGVIvarOffsetObjc)
#endif