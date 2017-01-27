[![Host.swift](https://github.com/rjstelling/Host.swift/blob/master/Resources/Hero.png)](#)

[![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](#)
[![Platform](https://img.shields.io/badge/Platform-iOS, macOS & tvOS-lightgrey.svg?style=flat)](#)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)](https://github.com/rjstelling/Hostess.swift/blob/master/LICENSE)

A Swift implementation of [NSHost (Host in Swift)](https://developer.apple.com/reference/foundation/host) that works on iOS, OS X and tvOS. 

Hostess.swift is safe to use in a framework because it does not require a bridging header.

## Motivation

Hostess.swift was created because NSHost is unavailable on iOS and CFHost does not offer the full functionality of it OS X counterpart.
  					
In addition, those developers hoping for a pure-Swift solution were out of luck without using a bridging header.
  					
Hostess.swift does not use a bridging header, so is safe to use in Framework development. It is 100% Swift and tries to maintain as much type safety as the low level networking C API will allow.

## Example

``` swift
let host = Host()
let deviceIP = host.addresses.first
print("IP: \(deviceIP)") // Will print a dot-separated IP address, e.g: 17.24.2.55
```

## What happend to Host.swift? 

[Host.swift](https://github.com/rjstelling/Host.swift) is still available but is considered end of life and I will not be maintaining it.

With the switch to Swift 3 Apple removed the NS prefix from many Foundation classes. This caused Host to clash with the renamed NSHost.

A new name was required... Hostess was chosen. 