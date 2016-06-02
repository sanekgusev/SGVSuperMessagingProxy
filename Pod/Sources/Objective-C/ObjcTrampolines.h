//
//  Trampolines.h
//  Pods
//
//  Created by Aleksandr Gusev on 25/05/16.
//
//

#pragma once

#include "TrampolineMacros.h"

SGVDeclareTrampolineFuction(SGVObjcMsgSendSuperTrampolineObjc)
SGVDeclareTrampolineFuction(SGVObjcMsgSendSuper2TrampolineObjc)

#if !defined(__arm64__)
SGVDeclareTrampolineFuction(SGVObjcMsgSendSuperStretTrampolineObjc)
SGVDeclareTrampolineFuction(SGVObjcMsgSendSuper2StretTrampolineObjc)
#else
#define SGVObjcMsgSendSuperStretTrampolineObjc NULL
#define SGVObjcMsgSendSuper2StretTrampolineObjc NULL
#endif