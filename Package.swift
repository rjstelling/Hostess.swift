// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Hostess",
	products: [
		.library(name: "Hostess", targets: ["Hostess"]),
		.executable(name: "Rose", targets: ["Rose"]),
	],
	targets: [
        .target(name: "Hostess", dependencies: [], path: "Projects/Hostess"),
        .target(name: "Rose", dependencies: ["Hostess"], path: "Projects/Rose"),
    ],
	swiftLanguageVersions: [4]
)