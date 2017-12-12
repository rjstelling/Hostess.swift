//
//  Hostess.swift
//
//  Created by Richard Stelling on 20/05/2016.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016-18 Richard Stelling (@rjstelling)
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

#if os(iOS) || os(tvOS)
import SystemConfiguration.CaptiveNetwork //SSID
#endif

let INET6_ADDRSTRLEN = UInt32(46)

extension ifaddrs {
    
    public enum Name: String {
        
        //iOS
        case localhost = "lo0"
        
        case ethernet = "en0"
        case ethernet1 = "en1"
        case ethernet2 = "en2"
        case ethernet3 = "en3"
        case ethernet4 = "en4"
        case ethernet5 = "en5"
        case ethernet6 = "en6"
        
        case celluar3G = "pdp_ip0"
        case tether = "pdp_ip1"
        
        case pdpip2 = "pdp_ip2"
        case pdpip3 = "pdp_ip3"
        case pdpip4 = "pdp_ip4"
        
        case vpn = "ppp0"
        case appleWirelessDirectLink = "awdl0"
        case accessPoint = "ap1"
        case tunnel0 = "utun0"
        case tunnel1 = "utun1"
        case tunnel2 = "utun2"
        case bridge100 = "bridge100"
        case ipsec0 = "ipsec0" // WiFi Calling
        case ipsec1 = "ipsec1" // WiFi Calling
        case ipsec2 = "ipsec2" // WiFi Calling
        
        public func description() -> String? {
            
            switch self {
            case .localhost: return "Local"
            case .ethernet: fallthrough
            case .ethernet1: fallthrough
            case .ethernet2: fallthrough
            case .ethernet3: fallthrough
            case .ethernet4: fallthrough
            case .ethernet5: fallthrough
            case .ethernet6:
                return "LAN"
            case .celluar3G: return "3G"
            case .vpn: return "VPN"
            case .appleWirelessDirectLink: return "WL"
            case .accessPoint: return "AP"
            case .tunnel0: return "TN0"
            case .tunnel1: return "TN1"
            case .tunnel2: return "TN2"
            case .bridge100: return "BRD"
            case .tether: return "THR"
            case .ipsec0: fallthrough
            case .ipsec1: fallthrough
            case .ipsec2: return "IPSEC"
                
                //Wifi calling????
            case .pdpip2: fallthrough
            case .pdpip3: fallthrough
            case .pdpip4: return "PDP"
                
            //default: return nil
            }
        }
    }
    
    var family: Int32 {
        return self.ifa_addr.pointee.family
    }
}

extension sockaddr {
    
    var family: Int32 {
        return Int32(self.sa_family)
    }
    
}

extension sockaddr_in {
    
    var family: Int32 {
        return Int32(self.sin_family)
    }
}

/*extension Hostess {
    
    static let hostessVersionNumber: Double = HostessVersionNumber
}*/

@available(iOS 9.3, OSX 10.11, *)
final public class Hostess {
    
    public struct Interface {
        
       public enum Family {
            case ipv4
            case ipv6
            case link
        }
        
        public let family: Family
        
        public let address: String
        //let ipv6Address: String
        
        public let name: ifaddrs.Name? //nil if unknown
    }
    
    /// Connected SSID if available
    #if os(iOS) || os(tvOS)
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
        return getAddresses().flatMap { $0.family == .ipv4 ? $0.address : nil }
    }
    
    ///Unordered list of Interfaces
    public var interfaces: [Interface] {
        return getAddresses()
    }
    
    public func interface(named name: ifaddrs.Name) -> [Interface] {
        return self.interfaces.filter { $0.name == name }
    }
    
    public init() {}
    
    #if os(iOS) || os(tvOS)
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
    
    fileprivate func getAddresses() -> [Interface] {
        
        var addresses: [Interface] = []
        //var interfaces = UnsafeMutablePointer<ifaddrs>(nil)
        // How many interface will we get? Will it crash if not enough?
        var interfaces: UnsafeMutablePointer<ifaddrs>? = nil
        
        // Use `getifaddrs()` to fill the ifaddrs struct, this is a linked list
        guard getifaddrs(&interfaces) == 0 else {
            return []
        }
        
        defer {
            freeifaddrs(interfaces)
        }
        
        // Our first address was returned above
        var currentInterface: ifaddrs! = interfaces?.pointee
        
        repeat {
            
            let interfaceName = String(cString: currentInterface.ifa_name, encoding: String.Encoding.utf8) ?? ""
            //let addressInfo = unsafeBitCast(currentInterface.ifa_addr.pointee, to: sockaddr_in.self)
            
            
            //var fam = currentInterface.ifa_addr.pointee.sa_family
            //let testSock = unsafeBitCast(currentInterface.ifa_addr.pointee, to: sockaddr_in6.self)
            
            //print("Interface: \(interfaceName) :: \(currentInterface.family)")
            
            switch currentInterface.family {
                
            case AF_INET: //2
                
                let addressInfo = unsafeBitCast(currentInterface.ifa_addr.pointee, to: sockaddr_in.self)
                
                if let ipAddress = String(cString: inet_ntoa(addressInfo.sin_addr), encoding: String.Encoding.utf8) {
                    addresses.append(Interface(family: .ipv4, address: ipAddress, name: ifaddrs.Name(rawValue: interfaceName)))
                }
                //print("\(addressInfo)")
                break
            
            case AF_INET6: //30
                
                let addressInfo: String = currentInterface.ifa_addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { sock in
                    
                    let sz = MemoryLayout<in6_addr>.size
                    let alg = MemoryLayout<in6_addr>.alignment
                    
                    let bytesPointer = UnsafeMutableRawPointer.allocate(bytes: sz, alignedTo: alg)
                    bytesPointer.storeBytes(of: sock.pointee.sin6_addr, as: in6_addr.self)

                    
                    let chars: UnsafeMutablePointer<Int8>? = UnsafeMutablePointer<Int8>.allocate(capacity: Int(INET6_ADDRSTRLEN))
                    
                    let cStr = inet_ntop(AF_INET6, bytesPointer, chars, INET6_ADDRSTRLEN)
                    let ipv6Str = String(cString: cStr!, encoding: String.Encoding.utf8)
					
					bytesPointer.deallocate(bytes: sz, alignedTo: alg)
					chars?.deallocate(capacity: Int(INET6_ADDRSTRLEN))
                    return "\(ipv6Str!)"
                }
                
                addresses.append(Interface(family: .ipv6, address: addressInfo, name: ifaddrs.Name(rawValue: interfaceName)))
                
                //print("\(addressInfo)")
                break
                
            case AF_LINK: //18
                
            
                //let addrInfo = unsafeBitCast(currentInterface.ifa_addr.pointee, to: sockaddr.self)
                //let dl = unsafeBitCast(addrInfo.sa_data, to: sockaddr_dl.self)
                //let addrInfo2 = unsafeBitCast(currentInterface.ifa_addr.sa_data, to: sockaddr_dl.self)
                //print("LINK... \(interfaceName) -> \(dl)")
                //let dl = UnsafeBufferPointer(start: currentInterface.ifa_addr.pointee, count: 1)
                //let addressInfo = unsafeBitCast(currentInterface.ifa_data, to: sockaddr_dl.self)
                
                //link = (struct sockaddr_dl*)a->addr->sa_data;
                
                break
                
            default:
                //print("\(interfaceName) Family: \(addressInfo.family)")
                break
            }
            
            if currentInterface.ifa_next != nil {
                currentInterface = currentInterface.ifa_next.pointee
            }
            else {
                currentInterface = nil
            }
            
        } while currentInterface != nil
        
        return addresses
    }
}
