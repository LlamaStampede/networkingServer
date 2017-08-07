//
//  Server.swift
//  Test
//
//  Created by Tyler Chermely on 8/3/17.
//  Copyright © 2017 TylerC. All rights reserved.
//

import Foundation
import SwiftSocket

class Server
{
    public static var instance : Server = Server()
    
    public private(set) var isRunning : Bool
    public private(set) var server : TCPServer?
    public private(set) var clients : [TCPClient]
    
    private init()
    {
        isRunning = false
        clients = []
    }
    
    public func startServer(address : inout String) -> Bool
    {
        if testServer(address : &address)
        {
            isRunning = true
            return true
        }
        
        return false
    }
    
    public func updateServer() -> Bool
    {
        if isRunning
        {
            if var client = server?.accept(timeout: 1) {
                clients.append(client)
                client.send(string: "GET / HTTP/1.0\n\n" )
                echoService(client: &client)

                return true
            } else {
                return false
            }
        }
        
        return false
    }
    
    public func getClients() -> [TCPClient]
    {
        return clients
    }
    
    func echoService(client: inout TCPClient) {
        print("Newclient from:\(client.address)[\(client.port)]")
        //var d = client.read(1024*10)
        //client.send(data: d!)
        client.send(string: "HI, from the server!")
        //client.close()
    }
    
    func testServer(address : inout String) ->Bool {
        var actualAddress = getIFAddresses()
        server = TCPServer(address: actualAddress, port: 8080)
        switch server?.listen() {
        case .success?:
            address = actualAddress
            return true
        case .failure(let error)?:
            print(error)
            return false
        default:
            print("PROBLEM")
            return false
        }
    }
    
    func getIFAddresses() -> String {
        
        var addresses = [String]()
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return "" }
        guard let firstAddr = ifaddr else { return "" }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
        }
        
        var result : String = ""
        for test in addresses
        {
            if test.isNumeric
            {
                result = test
                break
            }
        }
        
        freeifaddrs(ifaddr)
        return result
    }
}

extension String {
    var isNumeric: Bool {
        guard self.characters.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."]
        return Set(self.characters).isSubset(of: nums)
    }
}
