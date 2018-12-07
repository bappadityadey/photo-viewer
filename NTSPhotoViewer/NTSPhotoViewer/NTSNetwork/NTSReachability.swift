//
//  NTSReachability.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 26/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import Foundation
import SystemConfiguration

/// Defines different types of Reachability errors
enum ReachabilityError: Error {
    case FailedToCreateWithAddress(sockaddr_in)
    case FailedToCreateWithHostname(String)
    case UnableToSetCallback
    case UnableToSetDispatchQueue
}

@available(*, unavailable, renamed: "Notification.Name.reachabilityChanged")
let ReachabilityChangedNotification = NSNotification.Name("ReachabilityChangedNotification")

extension Notification.Name {
    static let reachabilityChanged = Notification.Name("reachabilityChanged")
}

/// This method calls back whenever reachability status gets changed.
/// - Parameters:
///   - reachability: An SCNetworkReachability instance
///   - flags: An SCNetworkReachabilityFlags instance
///   - info: An UnsafeMutableRawPointer instance
func callback(reachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
    
    guard let info = info else { return }
    
    let reachability = Unmanaged<NTSReachability>.fromOpaque(info).takeUnretainedValue()
    reachability.reachabilityChanged()
}

/// This will class handles the reachability paradigm
class NTSReachability {
    
    // MARK: Variables
    /// Network rechable closure
    typealias NetworkReachable = (NTSReachability) -> Void
    /// Network unrechable closure
    typealias NetworkUnreachable = (NTSReachability) -> Void
    
    /// Reachability network status list
    @available(*, unavailable, renamed: "Conection")
    enum NetworkStatus: CustomStringConvertible {
        case notReachable, reachableViaWiFi, reachableViaWWAN
        var description: String {
            switch self {
            case .reachableViaWWAN: return "Cellular"
            case .reachableViaWiFi: return "WiFi"
            case .notReachable: return "No Connection"
            }
        }
    }
    
    /// Reachability connection list
    enum Connection: CustomStringConvertible {
        case none, wifi, cellular
        var description: String {
            switch self {
            case .cellular: return "Cellular"
            case .wifi: return "WiFi"
            case .none: return "No Connection"
            }
        }
    }
    
    /// A Boolean which idenfies if the network is reachable
    var whenReachable: NetworkReachable?
    /// A Boolean which idenfies if the network is not reachable
    var whenUnreachable: NetworkUnreachable?
    
    /// A Boolean which identifes if the network is reachable on WWAN
    @available(*, deprecated: 4.0, renamed: "allowsCellularConnection")
    let reachableOnWWAN: Bool = true
    
    /// Set to `false` to force Reachability.connection to .none when on cellular connection (default value `true`)
    var allowsCellularConnection: Bool
    
    /// The notification center on which "reachability changed" events are being posted
    var notificationCenter: NotificationCenter = NotificationCenter.default
    
    /// Defines current reachability name
    @available(*, deprecated: 4.0, renamed: "connection.description")
    var currentReachabilityString: String {
        return "\(connection)"
    }
    
    /// A Connection instance which defines the current reachability status
    @available(*, unavailable, renamed: "connection")
    var currentReachabilityStatus: Connection {
        return connection
    }
    
    /// Defines currently connected connection instance
    var connection: Connection {
        
        guard isReachableFlagSet else { return .none }
        
        // If we're reachable, but not on an iOS device (i.e. simulator), we must be on WiFi
        guard isRunningOnDevice else { return .wifi }
        
        var connection = Connection.none
        
        if !isConnectionRequiredFlagSet {
            connection = .wifi
        }
        
        if isConnectionOnTrafficOrDemandFlagSet {
            if !isInterventionRequiredFlagSet {
                connection = .wifi
            }
        }
        
        if isOnWWANFlagSet {
            if !allowsCellularConnection {
                connection = .none
            } else {
                connection = .cellular
            }
        }
        
        return connection
    }
    
    /// A Previous Network Reachability Flag
    fileprivate var previousFlags: SCNetworkReachabilityFlags?
    
    /// A Boolean which identifies whether the app is running on device/simulator
    fileprivate var isRunningOnDevice: Bool = {
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }()
    
    /// A Boolean which identifes whether the reachability notifier is running or not
    fileprivate var notifierRunning = false
    /// SCNetworkReachability instnace
    fileprivate let reachabilityRef: SCNetworkReachability
    /// A Serial Queue which is being used to notify whenever the reachability gets changed
    fileprivate let reachabilitySerialQueue = DispatchQueue(label: "uk.co.ashleymills.reachability")
    
    /// Initialisation
    /// - Parameter:
    ///  - reachabilityRef: An SCNetworkReachability instance
    required init(reachabilityRef: SCNetworkReachability) {
        allowsCellularConnection = true
        self.reachabilityRef = reachabilityRef
    }
    
    /// Convenience Init
    /// - Parameters:
    ///   - hostname: Network Host Name
    convenience init?(hostname: String) {
        
        guard let ref = SCNetworkReachabilityCreateWithName(nil, hostname) else { return nil }
        
        self.init(reachabilityRef: ref)
    }
    
    /// Convenience Init
    convenience init?() {
        
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        guard let ref = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress) else { return nil }
        
        self.init(reachabilityRef: ref)
    }
    
    /// Deinitializer
    deinit {
        stopNotifier()
    }
}

extension NTSReachability {
    
    // MARK: - *** Notifier methods ***
    /// Starts Network notifier
    func startNotifier() throws {
        
        guard !notifierRunning else { return }
        
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutableRawPointer(Unmanaged<NTSReachability>.passUnretained(self).toOpaque())
        if !SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context) {
            stopNotifier()
            throw ReachabilityError.UnableToSetCallback
        }
        
        if !SCNetworkReachabilitySetDispatchQueue(reachabilityRef, reachabilitySerialQueue) {
            stopNotifier()
            throw ReachabilityError.UnableToSetDispatchQueue
        }
        
        // Perform an initial check
        reachabilitySerialQueue.async {
            self.reachabilityChanged()
        }
        
        notifierRunning = true
    }
    
    /// Stops Network notifier
    func stopNotifier() {
        defer { notifierRunning = false }
        
        SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachabilityRef, nil)
    }
    
    // MARK: - *** Connection test methods ***
    /// A Boolean which identifies whether the network is reachable or not
    @available(*, deprecated: 4.0, message: "Please use `connection != .none`")
    var isReachable: Bool {
        
        guard isReachableFlagSet else { return false }
        
        if isConnectionRequiredAndTransientFlagSet {
            return false
        }
        
        if isRunningOnDevice {
            if isOnWWANFlagSet && !reachableOnWWAN {
                // We don't want to connect when on cellular connection
                return false
            }
        }
        
        return true
    }
    
    /// A Boolean which identifies whether the network is reachable on WWAN
    @available(*, deprecated: 4.0, message: "Please use `connection == .cellular`")
    var isReachableViaWWAN: Bool {
        // Check we're not on the simulator, we're REACHABLE and check we're on WWAN
        return isRunningOnDevice && isReachableFlagSet && isOnWWANFlagSet
    }
    
    /// A Boolean which identifies whether the network is reachable on Wifi
    @available(*, deprecated: 4.0, message: "Please use `connection == .wifi`")
    var isReachableViaWiFi: Bool {
        
        // Check we're reachable
        guard isReachableFlagSet else { return false }
        
        // If reachable we're reachable, but not on an iOS device (i.e. simulator), we must be on WiFi
        guard isRunningOnDevice else { return true }
        
        // Check we're NOT on WWAN
        return !isOnWWANFlagSet
    }
    
    /// A Reachability description
    var description: String {
        
        let W = isRunningOnDevice ? (isOnWWANFlagSet ? "W" : "-") : "X"
        let R = isReachableFlagSet ? "R" : "-"
        let c = isConnectionRequiredFlagSet ? "c" : "-"
        let t = isTransientConnectionFlagSet ? "t" : "-"
        let i = isInterventionRequiredFlagSet ? "i" : "-"
        let C = isConnectionOnTrafficFlagSet ? "C" : "-"
        let D = isConnectionOnDemandFlagSet ? "D" : "-"
        let l = isLocalAddressFlagSet ? "l" : "-"
        let d = isDirectFlagSet ? "d" : "-"
        
        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)"
    }
}

fileprivate extension NTSReachability {
    
    /// This method gets triggered whenever the reachability status gets changed
    func reachabilityChanged() {
        guard previousFlags != flags else { return }
        
        let block = connection != .none ? whenReachable : whenUnreachable
        
        DispatchQueue.main.async {
            block?(self)
            self.notificationCenter.post(name: .reachabilityChanged, object: self)
        }
        
        previousFlags = flags
    }
    
    /// A Boolean which identifies if WWAN flag is set
    var isOnWWANFlagSet: Bool {
        #if os(iOS)
        return flags.contains(.isWWAN)
        #else
        return false
        #endif
    }
    /// A Boolean which identifies if reachable flag is set
    var isReachableFlagSet: Bool {
        return flags.contains(.reachable)
    }
    /// A Boolean which identifies if connectionRequired flag is set
    var isConnectionRequiredFlagSet: Bool {
        return flags.contains(.connectionRequired)
    }
    /// A Boolean which identifies if interventionRequired flag is set
    var isInterventionRequiredFlagSet: Bool {
        return flags.contains(.interventionRequired)
    }
    /// A Boolean which identifies if connectionOnTraffic flag is set
    var isConnectionOnTrafficFlagSet: Bool {
        return flags.contains(.connectionOnTraffic)
    }
    /// A Boolean which identifies if connectionOnDemand flag is set
    var isConnectionOnDemandFlagSet: Bool {
        return flags.contains(.connectionOnDemand)
    }
    /// A Boolean which identifies if connectionOnTraffic, connectionOnDemand flags are set
    var isConnectionOnTrafficOrDemandFlagSet: Bool {
        return !flags.intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty
    }
    /// A Boolean which identifes if transientConnection flag is set
    var isTransientConnectionFlagSet: Bool {
        return flags.contains(.transientConnection)
    }
    /// A Boolean which identifes if isLocalAddress flag is set
    var isLocalAddressFlagSet: Bool {
        return flags.contains(.isLocalAddress)
    }
    /// A Boolean which identifes if isDirect flag is set
    var isDirectFlagSet: Bool {
        return flags.contains(.isDirect)
    }
    /// A Boolean which identifes if connectionRequired, transientConnection, connectionRequired, transientConnection flags is set
    var isConnectionRequiredAndTransientFlagSet: Bool {
        return flags.intersection([.connectionRequired, .transientConnection]) == [.connectionRequired, .transientConnection]
    }
    /// Returns SCNetworkReachabilityFlags
    var flags: SCNetworkReachabilityFlags {
        var flags = SCNetworkReachabilityFlags()
        if SCNetworkReachabilityGetFlags(reachabilityRef, &flags) {
            return flags
        } else {
            return SCNetworkReachabilityFlags()
        }
    }
}
