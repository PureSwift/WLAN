import PackageDescription

#if os(macOS)
let nativeDependency: Target.Dependency = .Target(name: "DarwinWLAN")
#elseif os(Linux)
let nativeDependency: Target.Dependency = .Target(name: "LinuxWLAN")
#endif

let package = Package(
    name: "WLAN",
    targets: [
        Target(
            name: "WLAN",
            dependencies: [
                
            ]),
        Target(
            name: "DarwinWLAN",
            dependencies: [
                .Target(name: "WLAN")
            ]),
        Target(
            name: "Netlink",
            dependencies: [
                .Target(name: "WLAN"),
                .Target(name: "CLinuxWLAN"),
                .Target(name: "CNetlink")
            ]),
        Target(
            name: "LinuxWLAN",
            dependencies: [
                .Target(name: "WLAN"),
                .Target(name: "CLinuxWLAN"),
                .Target(name: "Netlink")
            ]),
        Target(
            name: "CLinuxWLAN"),
        Target(
            name: "CNetlink"),
        Target(
            name: "WLANTests",
            dependencies: [
                .Target(name: "WLAN"),
                nativeDependency
            ]),
        Target(
            name: "wirelesstool",
            dependencies: [
                .Target(name: "WLAN"),
                nativeDependency
            ])
    ],
    exclude: ["Xcode", "Carthage"]
)
