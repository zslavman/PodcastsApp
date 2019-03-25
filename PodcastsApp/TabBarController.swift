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
	
	public let favController = ViewController()
	public let searchNavController = UINavigationController(rootViewController: ViewController())
	public let downloadNavController = UINavigationController(rootViewController: ViewController())
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .green
		setupTabs()
	}
	
	
	

	
	
	
	
	private func setupTabs(){
		favController.tabBarItem.title = "Любимые"
		favController.tabBarItem.image = #imageLiteral(resourceName: "favorites")
		
		searchNavController.tabBarItem.title = "Поиск"
		searchNavController.tabBarItem.image = #imageLiteral(resourceName: "search")
		
		downloadNavController.tabBarItem.title = "Загрузки"
		downloadNavController.tabBarItem.image = #imageLiteral(resourceName: "downloads")
		
		viewControllers = [
			favController,
			searchNavController,
			downloadNavController
		]
		
		
	}
	
	
	
}
