//
//  AppLogger.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 11/21/25.
//

import Foundation

final class AppLoggerManager
{

    static let shared = AppLoggerManager()

    private init() {
        createLogFileIfNeeded()
    }

    private let fileName = "skylink.log"

    private var logFileURL: URL {
        let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("Logs").appendingPathComponent(fileName)
    }

    private func createLogFileIfNeeded() {
        let logsFolder = logFileURL.deletingLastPathComponent()

        if !FileManager.default.fileExists(atPath: logsFolder.path) {
            try? FileManager.default.createDirectory(at: logsFolder, withIntermediateDirectories: true)
        }

        if !FileManager.default.fileExists(atPath: logFileURL.path) {
            FileManager.default.createFile(atPath: logFileURL.path, contents: nil)
        }
    }

    func log(_ message: String)
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy h:mma"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        let timestamp = formatter.string(from: Date())
        let fullMessage = "[\(timestamp)] \(message)\n"

        if let handle = try? FileHandle(forWritingTo: logFileURL) {
            handle.seekToEndOfFile()
            if let data = fullMessage.data(using: .utf8) {
                handle.write(data)
            }
            try? handle.close()
        } else {
            print("Could not write to log file")
        }

        #if DEBUG
        #warning("Remove")
        //print("LOG:", fullMessage)
        #endif
    }

    func readLogs() -> String {
        do {
            let data = try Data(contentsOf: logFileURL)
            return String(data: data, encoding: .utf8) ?? "⚠️ Unable to decode log file"
        } catch {
            return "Failed to read log file: \(error.localizedDescription)"
        }
    }

    func clearLogs() {
        do {
            // Overwrite the file with empty data
            try "".data(using: .utf8)?.write(to: logFileURL)
            #if DEBUG
            print("LOG: Logs cleared successfully")
            #endif
        } catch {
            print("Failed to clear logs: \(error.localizedDescription)")
        }
    }
}
extension AppLoggerManager {

    func logServerDetails(_ server: Server?) {
        guard let server = server else {
            log("[Server Details] No server provided (nil)")
            return
        }

        // Helper for safe optional printing
        func val<T>(_ v: T?) -> String {
            v.map { "\($0)" } ?? "N/A"
        }

        log("""
        \n===============================
        [Server Details]
        -------------------------------
        Name: \(server.name)
        Nickname: \(val(server.nickname))
        City: \(val(server.city))
        State: \(val(server.state))
        Country: \(val(server.country))
        IP: \(val(server.publicIP))
        Port: \(val(server.port))
        Allows Connection: \(val(server.allowNewConnection))
        OS Version: \(val(server.osVersion))
        Last Updated: \(server.lastUpdated)
        Requires Subscription: \(server.requiresSubscription)
        ===============================
        """)
    }
}
//struct Server: Codable, Identifiable
//{
//    var id: String { name }
//    let name: String
//    let nickname: String?
//    let location: String?
//    let country: String?
//    let state: String?
//    let city: String?
//    let publicIP: String?
//    let osVersion: String?
//    let requiresSubscription: Bool
//    let capacity: Int
//    let currentCapacity: Int
//    let lastUpdated: String
//    let allowNewConnection: Bool?
//    let port: Int?
//}
//
