//
//  SceneDelegate.swift
//  BackgroundFetchLifecycleDemo
//
//  Created by Tomoya Hirano on 2025/12/07.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        BackgroundFetchLogger.shared.log("Scene will connect to session", event: "Scene")
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: ViewController())
        window?.makeKeyAndVisible()
        
        BackgroundFetchLogger.shared.log("window maked key and visible", event: "Scene")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        BackgroundFetchLogger.shared.log("Scene did disconnect", event: "Scene")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        BackgroundFetchLogger.shared.log("Scene did become active", event: "Scene")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        BackgroundFetchLogger.shared.log("Scene will resign active", event: "Scene")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        BackgroundFetchLogger.shared.log("Scene will enter foreground", event: "Scene")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        BackgroundFetchLogger.shared.log("Scene did enter background", event: "Scene")
    }


}

