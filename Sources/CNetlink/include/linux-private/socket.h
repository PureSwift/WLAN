#ifndef _LINUX_SOCKET_H
#define _LINUX_SOCKET_H

#define AF_NETLINK    16

/* "Socket"-level control message types: */

#define    SCM_RIGHTS    0x01        /* rw: access rights (array of int) */
#define SCM_CREDENTIALS 0x02        /* rw: struct ucred        */
#define SCM_SECURITY    0x03        /* rw: security label        */

/*
 * Desired design of maximum size and alignment (see RFC2553)
 */
#define _K_SS_MAXSIZE	128	/* Implementation specific max size */
#define _K_SS_ALIGNSIZE	(__alignof__ (struct sockaddr *))
				/* Implementation specific desired alignment */

typedef unsigned short __kernel_sa_family_t;

struct __kernel_sockaddr_storage {
	__kernel_sa_family_t	ss_family;		/* address family */
	/* Following field(s) are implementation specific */
	char		__data[_K_SS_MAXSIZE - sizeof(unsigned short)];
				/* space to achieve desired size, */
				/* _SS_MAXSIZE value minus size of ss_family */
} __attribute__ ((aligned(_K_SS_ALIGNSIZE)));	/* force desired alignment */

#endif /* _LINUX_SOCKET_H */
