//
//  AppDelegate.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 25.03.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	let reachability = Reachability()!

	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.makeKeyAndVisible()
		window?.rootViewController = TabBarController()
		startMonitoringNetwork()
		return true
	}
	
	
	private func startMonitoringNetwork() {
		NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged),
											   name: .reachabilityChanged, object: reachability)
		do {
			try reachability.startNotifier()
		}
		catch {
			print("could not start reachability notifier")
		}
	}
	
	
	@objc private func reachabilityChanged(note: Notification) {
		let reachability = note.object as! Reachability
		switch reachability.connection {
		case .wifi:
			print("Reachable via WiFi")
		case .cellular:
			print("Reachable via Cellular")
		case .none:
			print("Network not reachable!")
		}
	}

}

