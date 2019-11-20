//
//  AppDelegate.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 25.03.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit
import SwiftyStoreKit


protocol Rotatable where Self: UIViewController { // allow for VC only
	func resetToPortrait()
}
extension Rotatable {
	func resetToPortrait() {
		UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
	}
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var reachabilityService: ReachabilityService! // this instance must exist with application (not in closure)

	func application(_ application: UIApplication,
					 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		reachabilityService = ReachabilityService()
		_ = IAPManager.shared // init IAPManager
		JSONDownloadService.shared.downloadNewJSON()
		
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.makeKeyAndVisible()
		window?.rootViewController = TabBarController()
		return true
	}

	
	func applicationDidBecomeActive(_ application: UIApplication) {
		_ = SettingsBundleHelper()
		JSONDownloadService.shared.downloadNewJSON()
	}
	
	
	// The app disables rotation for all view controllers except for a few that opt-in by
	// conforming to the Rotatable protocol
	func application(_ application: UIApplication,
					 supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		guard let _ = getTopVC(for: window?.rootViewController) as? Rotatable else {
			return .portrait
		}
		return .allButUpsideDown
	}
	
	
	private func getTopVC(for rootViewController: UIViewController!) -> UIViewController? {
		guard let rootVC = rootViewController else { return nil }
		
		if rootVC is UITabBarController {
			let rootTabBarVC = rootVC as! UITabBarController
			return getTopVC(for: rootTabBarVC.selectedViewController)
		}
		else if rootVC is UINavigationController {
			let rootNavVC = rootVC as! UINavigationController
			return getTopVC(for: rootNavVC.visibleViewController)
		}
		else if let rootPresentedVC = rootVC.presentedViewController {
			return getTopVC(for: rootPresentedVC)
		}
		return rootViewController
	}
	
	
	
//	func application(_ application: UIApplication,
//					 supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//		if let rootViewController = topVC_with_rootVC(rootViewController: window?.rootViewController) {
//			if (rootViewController.responds(to: Selector(("canRotate")))) { // canRotate - name of method in VC
//				// Unlock landscape view orientations for this view controller
//				return .allButUpsideDown
//			}
//		}
//		// Only allow portrait (standard behaviour)
//		return .portrait
//	}
	/// every VC which have this method can changing orientation
	//@objc func canRotate() -> Void {}
	
//	private func topVC_with_rootVC(rootViewController: UIViewController!) -> UIViewController? {
//		if (rootViewController == nil) { return nil }
//		if (rootViewController.isKind(of: UITabBarController.self)) {
//			return topVC_with_rootVC(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
//		}
//		else if (rootViewController.isKind(of: UINavigationController.self)) {
//			return topVC_with_rootVC(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
//		}
//		else if (rootViewController.presentedViewController != nil) {
//			return topVC_with_rootVC(rootViewController: rootViewController.presentedViewController)
//		}
//		return rootViewController
//	}
	
}

