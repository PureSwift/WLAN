// swift-tools-version:5.5
import PackageDescription
import class Foundation.ProcessInfo

// force building as dynamic library
let dynamicLibrary = ProcessInfo.processInfo.environment["SWIFT_BUILD_DYNAMIC_LIBRARY"] != nil
let libraryType: PackageDescription.Product.Library.LibraryType? = dynamicLibrary ? .dynamic : nil

var package = Package(
    name: "WLAN",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
    products: [
        .library(
            name: "WLAN",
            type: libraryType,
            targets: ["WLAN"]
        ),
        .library(
            name: "DarwinWLAN",
            targets: ["DarwinWLAN"]
        ),
        .library(
            name: "LinuxWLAN",
            type: libraryType,
            targets: ["LinuxWLAN"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/PureSwift/Netlink.git",
            .branch("master")
        )
    ],
    targets: [
        .target(
            name: "WLAN"
        ),
        .target(
            name: "DarwinWLAN",
            dependencies: [
                .target(name: "WLAN")
            ]
        ),
        .target(
            name: "LinuxWLAN",
            dependencies: [
                .target(
                    name: "WLAN"
                ),
                .product(
                    name: "Netlink",
                    package: "Netlink"
                ),
                .product(
                    name: "NetlinkGeneric",
                    package: "Netlink"
                ),
                .product(
                    name: "Netlink80211",
                    package: "Netlink"
                )
            ]
        ),
        .executableTarget(
            name: "wirelesstool",
            dependencies: [
                .target(
                    name: "WLAN"
                ),
                .target(
                    name: "DarwinWLAN",
                    condition: .when(platforms: [.macOS])
                ),
                .target(
                    name: "LinuxWLAN",
                    condition: .when(platforms: [.linux])
                )
            ]
        ),
        .testTarget(
            name: "WLANTests",
            dependencies: [
                .target(
                    name: "WLAN"
                ),
            ]
        ),
    ]
)

// SwiftPM command plugins are only supported by Swift version 5.6 and later.
#if swift(>=5.6)
let buildDocs = ProcessInfo.processInfo.environment["BUILDING_FOR_DOCUMENTATION_GENERATION"] != nil
if buildDocs {
    package.dependencies += [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ]
}
#endif
