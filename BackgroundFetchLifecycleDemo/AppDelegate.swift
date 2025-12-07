//
//  AppDelegate.swift
//  BackgroundFetchLifecycleDemo
//
//  Created by Tomoya Hirano on 2025/12/07.
//

import UIKit
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let refreshTaskIdentifier = "dev.noppe.BackgroundFetchLifecycleDemo.refresh"

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        BackgroundFetchLogger.shared.log("Application did finish launching", event: "Lifecycle")
        // Background Fetchの設定
        // Removed minimum background fetch interval setup and logging
        
        // Launch optionsのチェック
        if let launchOptions = launchOptions {
            for (key, value) in launchOptions {
                BackgroundFetchLogger.shared.log("Launch option: \(key.rawValue) = \(value)", event: "Launch")
            }
        }
        
        // Register BackgroundTasks refresh handler (iOS 13+)
        let registered = BGTaskScheduler.shared.register(forTaskWithIdentifier: AppDelegate.refreshTaskIdentifier, using: nil) { task in
            BackgroundFetchLogger.shared.log("BGAppRefreshTask handler called", event: "BackgroundFetch")
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        if registered {
            BackgroundFetchLogger.shared.log("BGTaskScheduler registered successfully", event: "BackgroundFetch")
        } else {
            BackgroundFetchLogger.shared.log("Failed to register BGTaskScheduler", event: "BackgroundFetch")
        }
        
        return true
    }
    
    // Background Fetchのメイン処理
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        BackgroundFetchLogger.shared.log("Background fetch started", event: "BackgroundFetch")
        
        // 実際のバックグラウンド処理をシミュレート
        simulateBackgroundTask { result in
            BackgroundFetchLogger.shared.log("Background fetch completed with result: \(result)", event: "BackgroundFetch")
            completionHandler(result)
        }
    }
    
    // MARK: - BackgroundTasks (BGAppRefreshTask)
    @available(iOS 13.0, *)
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: AppDelegate.refreshTaskIdentifier)
        // Earliest begin date gives the system a hint; do not expect exact timing.
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes from now
        do {
            try BGTaskScheduler.shared.submit(request)
            BackgroundFetchLogger.shared.log("BGAppRefreshTask scheduled", event: "BackgroundFetch")
        } catch {
            BackgroundFetchLogger.shared.log("Failed to schedule BGAppRefreshTask: \(error)", event: "BackgroundFetch")
        }
    }

    @available(iOS 13.0, *)
    private func handleAppRefresh(task: BGAppRefreshTask) {
        BackgroundFetchLogger.shared.log("BGAppRefreshTask started", event: "BackgroundFetch")

        // Schedule the next refresh
        scheduleAppRefresh()

        // Provide an expiration handler to cancel work if the system needs to terminate early.
        var taskCompleted = false
        task.expirationHandler = { [weak self] in
            BackgroundFetchLogger.shared.log("BGAppRefreshTask expired", event: "BackgroundFetch")
            taskCompleted = true
            task.setTaskCompleted(success: false)
            // If you had ongoing work, cancel it here.
            _ = self // keep self captured if needed
        }

        // Reuse the same simulated background task; map its result to success/failure.
        simulateBackgroundTask { result in
            guard !taskCompleted else { return }
            let success: Bool
            switch result {
            case .newData, .noData:
                success = true
            case .failed:
                success = false
            @unknown default:
                success = false
            }
            BackgroundFetchLogger.shared.log("BGAppRefreshTask completed with success: \(success)", event: "BackgroundFetch")
            task.setTaskCompleted(success: success)
        }
    }
    
    private func simulateBackgroundTask(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        // 実際のアプリでは、ここでネットワーク通信やデータ処理を行う
        DispatchQueue.global(qos: .background).async {
            BackgroundFetchLogger.shared.log("Simulating background work...", event: "BackgroundFetch")
            
            // 2秒間の作業をシミュレート
            Thread.sleep(forTimeInterval: 2)
            
            // ランダムに結果を決定
            let results: [UIBackgroundFetchResult] = [.newData, .noData, .failed]
            let randomResult = results.randomElement() ?? .noData
            
            DispatchQueue.main.async {
                completion(randomResult)
            }
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        BackgroundFetchLogger.shared.log("Scene configuration for connecting", event: "Lifecycle")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        BackgroundFetchLogger.shared.log("Did discard scene sessions", event: "Lifecycle")
    }
    
    // MARK: Background Lifecycle Events
    
    func applicationWillResignActive(_ application: UIApplication) {
        BackgroundFetchLogger.shared.log("Application will resign active", event: "Lifecycle")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        BackgroundFetchLogger.shared.log("Application did enter background", event: "Lifecycle")
        
        // Schedule background refresh only when entering background
        if #available(iOS 13.0, *) {
            scheduleAppRefresh()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        BackgroundFetchLogger.shared.log("Application will enter foreground", event: "Lifecycle")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        BackgroundFetchLogger.shared.log("Application did become active", event: "Lifecycle")
    }
}

