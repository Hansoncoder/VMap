//
//  AppDelegate.swift
//  VMap
//
//  Created by Admin on 5/13/24.
//

import UIKit
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupGoogleMap()
        
        setupRootViewController()
        
        return true
    }
    
    private func setupRootViewController() {
        self.window = UIWindow()
        self.window?.backgroundColor = .white
        self.window?.rootViewController = VMapViewController()
        self.window?.makeKeyAndVisible()
    }
    
}

extension AppDelegate {
    private func setupGoogleMap() {
        GMSServices.provideAPIKey(VMapConfig.apiKey)
    }
}

