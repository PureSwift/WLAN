import PackageDescription

let package = Package(
    name: "WLAN",
    targets: [
        Target(
            name: "WLAN"),
        Target(
            name: "DarwinWLAN",
            dependencies: ["WLAN"]),
        Target(
            name: "LinuxWLAN",
            dependencies: ["WLAN"])
    ]
)
