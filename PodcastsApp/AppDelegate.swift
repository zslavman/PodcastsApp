//
//  AppDelegate.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 25.03.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var reachabilityService: ReachabilityService! // this instance must exist with application (not in closure)

	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		reachabilityService = ReachabilityService()
		IAPManager.shared.setDownloadsHandler() // init IAPManager
		JSONDownloadService.shared.downloadNewJSON()
		SwiftyStoreKit.completeTransactions {
			(pupchases) in
			print("did complete transaction \(pupchases)")
		}
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.makeKeyAndVisible()
		window?.rootViewController = TabBarController()
		return true
	}

	
	func applicationDidBecomeActive(_ application: UIApplication) {
		_ = SettingsBundleHelper()
		JSONDownloadService.shared.downloadNewJSON()
	}
	
}

