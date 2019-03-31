//
//  TabBarController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 25.03.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation
import UIKit


class TabBarController: UITabBarController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		UINavigationBar.appearance().prefersLargeTitles = true
		setupTabs()
	}
	
	private func setupTabs(){
		viewControllers = [
			createNavController(rootVC: PodcastsSearchController(), title: "Поиск", img: #imageLiteral(resourceName: "search")),
			createNavController(rootVC: ViewController(), title: "Любимые", img: #imageLiteral(resourceName: "favorites")),
			createNavController(rootVC: ViewController(), title: "Загрузки", img: #imageLiteral(resourceName: "downloads")),
		]
	}
	
	
	private func createNavController(rootVC: UIViewController, title: String, img: UIImage) -> UIViewController {
		let navVC = UINavigationController(rootViewController: rootVC)
		navVC.tabBarItem.title = title
		navVC.tabBarItem.image = img
		rootVC.navigationItem.title = title // title on top of VC
		return navVC
	}
	
	
	
}
