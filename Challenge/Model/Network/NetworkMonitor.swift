//
//  NetworkMonitor.swift
//  Challenge
//
//  Created by Linda adel on 1/28/22.
//

import Foundation
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let queue = DispatchQueue.global()
    private let monitor : NWPathMonitor
    
    public private(set) var isConnected : Bool = false
    {
        didSet{
            
            NotificationCenter.default.post(name: NSNotification.Name("internetConnectivity"), object: nil , userInfo: ["connectionStatus" : isConnected])
        }
    }

    
    public private(set) var connectionType : ConnectionType = .unKnown
    
    enum ConnectionType{
        case wifi
        case cellular
        case ethernet
        case unKnown
    }
    
    private init(){
        monitor = NWPathMonitor()
    }
    
    public func startMonitoring(){
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status != .unsatisfied
            self?.connectionType = .wifi
            self?.getConnectionType(path)
            print(self?.isConnected ?? "N/A")
        }
    }
    
    public func stopMonitoring(){
        monitor.cancel()
    }
    
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
