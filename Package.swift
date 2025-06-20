// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Arete",
    platforms: [
        .watchOS(.v10)
    ],
    products: [
        .executable(name: "Arete", targets: ["Arete"])
    ],
    targets: [
        .executableTarget(
            name: "Arete",
            path: "Arete Watch App",
            resources: [
                .process("Assets.xcassets"),
                .process("Arete Watch App.entitlements")
            ]
        ),
        .testTarget(
            name: "AreteTests",
            dependencies: ["Arete"],
            path: "Arete Watch AppTests"
        ),
        .testTarget(
            name: "AreteUITests",
            dependencies: ["Arete"],
            path: "Arete Watch AppUITests"
        )
    ]
)

