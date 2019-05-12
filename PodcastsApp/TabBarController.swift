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
	
	
	private var maximizedTopAnchorConstraint: NSLayoutConstraint!
	private var minimizedTopAnchorConstraint: NSLayoutConstraint!
	private let playerDetailsView = PlayerDetailsView.initFromNib()
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		UINavigationBar.appearance().prefersLargeTitles = true
		setupTabs()
		setupPlayerDetailsView()
	}
	
	
	
	private func setupPlayerDetailsView() {
		view.insertSubview(playerDetailsView, belowSubview: tabBar)
		
		maximizedTopAnchorConstraint =
			playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
		maximizedTopAnchorConstraint.isActive = true
		
		minimizedTopAnchorConstraint =
			playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
		//minimizedTopAnchorConstraint.isActive = true
		
		playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
	}
	
	
	@objc public func minimizePlayer() {
		maximizedTopAnchorConstraint.isActive = false
		minimizedTopAnchorConstraint.isActive = true
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.view.layoutIfNeeded()
			self.playerDetailsView.maximizedStackView.alpha = 0
			self.playerDetailsView.minimizedStackView.alpha = 1
		})
		self.tabBar.transform = .identity
	}
	
	
	public func maximizePlayer(episode: Episode?) {
		minimizedTopAnchorConstraint.isActive = false
		maximizedTopAnchorConstraint.constant = 0
		maximizedTopAnchorConstraint.isActive = true
		
		if episode != nil {
			playerDetailsView.episode = episode
		}
	
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.view.layoutIfNeeded()
			self.playerDetailsView.maximizedStackView.alpha = 1
			self.playerDetailsView.minimizedStackView.alpha = 0
		})
		self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100) // hide tabBar
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
