//
//  PacketTunnelProvider.swift
//  network-extension
//
//  Created by Developer on 10/6/25.
//

import NetworkExtension
import WireGuardKit

enum PacketTunnelProviderError: String, Error
{
    case invalidProtocolConfiguration
    case cantParseWgQuickConfig
}

class PacketTunnelProvider: NEPacketTunnelProvider
{

    private var statsTimer: Timer?
    
    
    private lazy var adapter: WireGuardAdapter =
    {
        return WireGuardAdapter(with: self) { [weak self] _, message in
            self?.log(message)
        }
    }()

    func log(_ message: String)
    {
        NSLog("WireGuard Tunnel: %@\n", message)
    }

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void)
    {
        log("Starting tunnel")
        guard let protocolConfiguration = self.protocolConfiguration as? NETunnelProviderProtocol,
              let providerConfiguration = protocolConfiguration.providerConfiguration,
              let wgQuickConfig = providerConfiguration["wgQuickConfig"] as? String else
        {
            log("Invalid provider configuration")
            completionHandler(PacketTunnelProviderError.invalidProtocolConfiguration)
            return
        }

        guard let tunnelConfiguration = try? TunnelConfiguration(fromWgQuickConfig: wgQuickConfig) else
        {
            log("wg-quick config not parseable")
            completionHandler(PacketTunnelProviderError.cantParseWgQuickConfig)
            return
        }

        adapter.start(tunnelConfiguration: tunnelConfiguration)
        { [weak self] adapterError in
            guard let self = self else { return }
            if let adapterError = adapterError
            {
                self.log("WireGuard adapter error: \(adapterError.localizedDescription)")
            }
            else
            {
                let interfaceName = self.adapter.interfaceName ?? "unknown"
                self.log("Tunnel interface is \(interfaceName)")
                
                //Periodic Reporting
                self.startStatsReportingLoop()
             
            }
            completionHandler(adapterError)
        }
    }
    
    

       

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        log("Stopping tunnel")
        adapter.stop { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.log("Failed to stop WireGuard adapter: \(error.localizedDescription)")
            }
            
            // Stop stats reporting when tunnel disconnects
            self.statsTimer?.invalidate()
            //clear stale values
            self.clearStatsOnDisconnect()
            completionHandler()

            #if os(macOS)
            // HACK: We have to kill the tunnel process ourselves because of a macOS bug
            exit(0)
            #endif
        }
       
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }

    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }

    override func wake() {
        // Add code here to wake up.
    }
}

extension PacketTunnelProvider {
    
    private func startStatsReportingLoop()
    {
        statsTimer?.invalidate()
        statsTimer = Timer(timeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.adapter.getRuntimeConfiguration { configTextOptional in
                guard let configText = configTextOptional else {
                    print("getRuntimeConfiguration returned nil")
                    return
                }

                var rxBytes: Double = 0
                var txBytes: Double = 0

                for line in configText.split(separator: "\n") {
                    if line.hasPrefix("rx_bytes=") || line.hasPrefix("transfer_rx=") {
                        rxBytes = Double(line
                            .replacingOccurrences(of: "rx_bytes=", with: "")
                            .replacingOccurrences(of: "transfer_rx=", with: "")
                        ) ?? 0
                    } else if line.hasPrefix("tx_bytes=") || line.hasPrefix("transfer_tx=") {
                        txBytes = Double(line
                            .replacingOccurrences(of: "tx_bytes=", with: "")
                            .replacingOccurrences(of: "transfer_tx=", with: "")
                        ) ?? 0
                    }
                }

                let defaults = UserDefaults(suiteName: "group.com.adebayosotannde.SkyLink")
                defaults?.set(rxBytes, forKey: "downloadSpeed")
                defaults?.set(txBytes, forKey: "uploadSpeed")
                defaults?.synchronize()

                print("RX: \(rxBytes) bytes | TX: \(txBytes) bytes")
            }
        }
        RunLoop.main.add(statsTimer!, forMode: .common)
    }
    
    private func clearStatsOnDisconnect() {
        let defaults = UserDefaults(suiteName: "group.com.adebayosotannde.SkyLink")
        defaults?.set(0.0, forKey: "downloadSpeed")
        defaults?.set(0.0, forKey: "uploadSpeed")
        defaults?.synchronize()
        print("[PacketTunnelProvider] Cleared shared stats (download/upload reset to 0)")
    }
}
