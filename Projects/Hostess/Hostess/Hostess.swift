//
//  Hostess.swift
//
//  Created by Richard Stelling on 20/05/2016.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Richard Stelling (@rjstelling)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import SystemConfiguration.CaptiveNetwork //SSID

// TODO:    - IPv6 Support
//          - WAN Address


@available(iOS 9.3, OSX 10.11, *)
final public class Hostess {
    
    /// Connected SSID if available
    #if os(iOS)
    public var ssid: String? {
        return getSSID()
    }
    #endif
    
    /// Host name if available
    public var name: String? {
        return getHostname()
    }
    
    /// Unordered list of IPv4 addresses
    public var addresses: [String] {
        return getAddresses()
    }
    
    public init() {}
    
    #if os(iOS)
    fileprivate func getSSID() -> String? {

        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return nil
        }
        
        for intf in interfaces {
            
            if let interface = CNCopyCurrentNetworkInfo(intf as CFString) as? [String : AnyObject] {
                
                return interface["SSID"] as? String
            }
        }
        
        return nil
    }
    #endif
    
    fileprivate func getHostname() -> String? {
        
        var hostname = [CChar](repeating: 0x0, count: Int(NI_MAXHOST))
        
        guard gethostname(&hostname, Int(NI_MAXHOST)) == noErr else {
            return nil
        }

        return String(cString: hostname, encoding: String.Encoding.utf8)
    }
    
    fileprivate func getAddresses() -> [String] {
        
        var addresses: [String] = []
        //var interfaces = UnsafeMutablePointer<ifaddrs>(nil)
        // How many interface will we get? Will it crash if not enough?
        var interfaces: UnsafeMutablePointer<ifaddrs>? = UnsafeMutablePointer<ifaddrs>.allocate(capacity: 32)
        
        // Use `getifaddrs()` to fill the ifaddrs struct, this is a linked list
        guard getifaddrs(&interfaces) == 0 else {
            return []
        }
        
        // Our first address was returned above
        #if swift(>=3.0)
            var currentInterface: ifaddrs! = interfaces?.pointee
        #else
            var currentInterface: ifaddrs! = interfaces.memory
        #endif
        
        repeat {
            
        #if swift(>=3.0)
            let addressInfo = unsafeBitCast(currentInterface.ifa_addr.pointee, to: sockaddr_in.self)
        #else
            let addressInfo = unsafeBitCast(currentInterface.ifa_addr.memory, to: sockaddr_in.self)
        #endif
            
            if let ipAddress = String(cString: inet_ntoa(addressInfo.sin_addr), encoding: String.Encoding.utf8), Int(addressInfo.sin_family) == Int(AF_INET) {
                addresses.append(ipAddress)
            }
            
            if currentInterface.ifa_next != nil {
                #if swift(>=3.0)
                    currentInterface = currentInterface.ifa_next.pointee
                #else
                    currentInterface = currentInterface.ifa_next.pointee
                #endif
            }
            else {
                currentInterface = nil
            }
            
        } while currentInterface != nil
        
        return addresses
    }
}
