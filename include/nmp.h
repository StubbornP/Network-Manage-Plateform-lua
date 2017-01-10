//
// Created by stubborn on 1/3/17.
//

#ifndef NETWORKMANAGEPLATEFORM_NMP_H
#define NETWORKMANAGEPLATEFORM_NMP_H

#include "types.h"

#include "lua_pcap.h"
#include "lua_ctx.h"
#include "lua_zookeeper.h"

#define IDEL_PEROID 5000

lua_State *aquireMachine();

int releaseMachine();

int init();

#endif //NETWORKMANAGEPLATEFORM_NMP_H
