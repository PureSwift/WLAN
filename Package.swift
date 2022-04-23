// swift-tools-version:5.5
import PackageDescription

let libraryType: PackageDescription.Product.Library.LibraryType = .static

let package = Package(
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
            type: libraryType,
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
