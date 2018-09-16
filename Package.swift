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
            name: "WLAN"
            ),
        Target(
            name: "DarwinWLAN",
            dependencies: [
                .Target(name: "WLAN")
            ]),
        Target(
            name: "LinuxWLAN",
            dependencies: [
                .Target(name: "WLAN")
            ]),
        Target(
            name: "WLANTests",
            dependencies: [
                .Target(name: "WLAN")
            ]),
        Target(
            name: "wirelesstool",
            dependencies: [
                .Target(name: "WLAN"),
                nativeDependency
            ])
    ],
    dependencies: [
        .Package(url: "https://github.com/PureSwift/CLinuxWLAN.git", majorVersion: 1),
        .Package(url: "https://github.com/PureSwift/Netlink.git", majorVersion: 1)
    ],
    exclude: ["Xcode", "Carthage"]
)
