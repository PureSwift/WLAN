/*
 *
 *  Swift WLAN Linux Stack
 *  MIT License
 *  PureSwift
 *
 * Created by Alsey Coleman Miller on 7/5/18.
 *
 */

#include <sys/types.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h> //fntnl (set descriptor options)

#ifdef linux
#include <linux/wireless.h>
#endif
