//
//  NetworkMonitor.swift
//  Challenge
//
//  Created by Linda adel on 1/28/22.
//

import Foundation
import Network

/// class for monitoring internet connectivity
final class NetworkMonitor {
    
    /// A shared instance
    static let shared = NetworkMonitor()
    
    /// A constant variable for class queue
    private let queue = DispatchQueue.global()
    
    /// A constant variable monitor for network path
    private let monitor : NWPathMonitor
    
    /// A boolean that indicate the internet connection status
    public private(set) var isConnected : Bool = false
    {
        didSet{
            
            NotificationCenter.default.post(name: NSNotification.Name("internetConnectivity"), object: nil , userInfo: ["connectionStatus" : isConnected])
        }
    }
    
    
    public private(set) var connectionType : ConnectionType = .unKnown
    
    /// An enum for different types of internet connection
    enum ConnectionType{
        case wifi
        case cellular
        case ethernet
        case unKnown
    }
    
    private init(){
        monitor = NWPathMonitor()
    }
    
    /// Method to listen to internet status
    public func startMonitoring(){
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
            self?.connectionType = .wifi
            self?.getConnectionType(path)
            print(self?.isConnected ?? "N/A")
        }
    }
    
    /// Method to cancel monitering for internet status
    public func stopMonitoring(){
        monitor.cancel()
    }
    
    /// Method to get the internet connection type
    /// - Parameter path: object of network path state
    private func getConnectionType(_ path: NWPath){
        if path.usesInterfaceType(.wifi){
            connectionType = .wifi
        }
        else if path.usesInterfaceType(.cellular){
            connectionType = .cellular
        }
        else if path.usesInterfaceType(.wiredEthernet){
            connectionType = .ethernet
        }
        else{
            connectionType = .unKnown
        }
    }
    
}
