# WLAN
Wireless LAN (WiFi) API for Swift (Supports Linux)

## Overview

This library provides a cross-platform API for interacting WiFi hardware and scanning for networks.
On macOS the [CoreWLAN](https://developer.apple.com/documentation/corewlan) framework is used to communicate with the Darwin kernel, while on Linux a [Netlink](https://en.wikipedia.org/wiki/Netlink) socket is used to communicate with the Linux kernel.
