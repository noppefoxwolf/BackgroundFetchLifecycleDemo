//
//  BackgroundFetchLogger.swift
//  BackgroundFetchLifecycleDemo
//
//  Created by Copilot on 2025/12/07.
//

import Foundation

class BackgroundFetchLogger {
    static let shared = BackgroundFetchLogger()
    private let logsKey = "BackgroundFetchLogs"
    private let maxLogCount = 100
    
    private init() {}
    
    func log(_ message: String, event: String = "General") {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let logEntry = "[\(timestamp)] \(event): \(message)"
        
        var logs = getLogs()
        logs.append(logEntry)
        
        // 最大ログ数を超えた場合は古いログを削除
        if logs.count > maxLogCount {
            logs = Array(logs.suffix(maxLogCount))
        }
        
        UserDefaults.standard.set(logs, forKey: logsKey)
        UserDefaults.standard.synchronize()
        
        print(logEntry)
    }
    
    func getLogs() -> [String] {
        return UserDefaults.standard.stringArray(forKey: logsKey) ?? []
    }
    
    func clearLogs() {
        UserDefaults.standard.removeObject(forKey: logsKey)
        UserDefaults.standard.synchronize()
    }
    
    func getFormattedLogs() -> String {
        let logs = getLogs()
        return logs.joined(separator: "\n")
    }
}