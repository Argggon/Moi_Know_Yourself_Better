// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Moi",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(
            name: "Moi",
            targets: ["Moi"]
        )
    ],
    targets: [
        .executableTarget(
            name: "Moi",
            path: ".",
            sources: [
                "App",
                "Models",
                "Services",
                "Utilities",
                "Views"
            ]
        )
    ]
)
