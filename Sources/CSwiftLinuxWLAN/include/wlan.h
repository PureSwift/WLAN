/*
 *
 *  Swift WLAN Linux Stack
 *  MIT License
 *  PureSwift
 *
 * Created by Alsey Coleman Miller on 7/5/18.
 *
 */

#include <sys/ioctl.h>
#include <sys/types.h>
#include <ifaddrs.h>

/**
 @brief Manipulates the underlying device parameters of special files.
 @discussion @c int ioctl(int d, int request, ...);
 @param fd An open file descriptor.
 @param request Device-dependent request code.
 @param pointer Untyped pointer to memory.
 */
static inline int swift_wlan_ioctl(int fd, int request, void *pointer)
__attribute__((swift_name("IOControl(_:_:_:)")))
{
    return ioctl(fd, request, pointer);
}
