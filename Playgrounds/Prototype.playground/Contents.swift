//: Playground - noun: a place where people can play

import UIKit

/// The Host class provides methods to access the network name and address information for a host.
final public class Hostess {
    
    /// Returns one of the network addresses of the receiver.
    public private(set) var address: String?
    
    /// Returns all the network addresses of the receiver.
    public private(set) var addresses: [String] = []
    
    /// Returns one of the hostnames of the receiver.
    public private(set) var name: String?
    
    /// Returns all the hostnames of the receiver.
    public private(set) var names: [String] = []
    
    /// Returns one of the network interfaces of the receiver.
    public private(set) var interface: Interface?
    
    /// Returns all the network interfaces of the receiver.
    public private(set) var interfaces: [Interface] = []
    
    /// Returns an NSHost object representing the host the process is running on.
    ///
    /// - Returns: Hostess object for the process’ host.
    class func current() -> Self {
        return self.init()
    }
}

// MARK: - Interfaces

extension Hostess {
    
    public struct Interface {
        
        public struct IPAddress {
            
            public enum IPVersion {
                case ipv4
                case ipv6
            }
            
            private let octets: [Int]
            
            let version: IPVersion
            
            func ipv4() -> String {
                return ""
            }
        }
        
        let name: String?
        let address: IPAddress
    }
}
