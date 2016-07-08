//
//  SwiftTrampolines.h
//  Pods
//
//  Created by Aleksandr Gusev on 29/05/16.
//
//

#pragma once

#include "TrampolineMacros.h"

SGVDeclareTrampolineFuction(SGVObjcMsgSendSuperTrampolineSwift)
SGVDeclareTrampolineFuction(SGVObjcMsgSendSuper2TrampolineSwift)

#if !defined(__arm64__)
SGVDeclareTrampolineFuction(SGVObjcMsgSendSuperStretTrampolineSwift)
SGVDeclareTrampolineFuction(SGVObjcMsgSendSuper2StretTrampolineSwift)
#else
#define SGVObjcMsgSendSuperStretTrampolineSwift NULL
#define SGVObjcMsgSendSuper2StretTrampolineSwift NULL
#endif
