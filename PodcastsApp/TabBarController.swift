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
	private var bottomAnchorConstraint: NSLayoutConstraint!
	public let playerDetailsView = PlayerDetailsView.initFromNib()
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		UINavigationBar.appearance().prefersLargeTitles = true
		setupTabs()
		setupPlayerDetailsView()
	}
	
	
	private func setupPlayerDetailsView() {
		view.insertSubview(playerDetailsView, belowSubview: tabBar)
		playerDetailsView.layer.shadowColor = UIColor.black.cgColor
		playerDetailsView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
		playerDetailsView.layer.shadowRadius = 4
		playerDetailsView.layer.shadowOpacity = 0.6
		playerDetailsView.layer.masksToBounds = false
		playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
		
		maximizedTopAnchorConstraint =
			playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
		maximizedTopAnchorConstraint.isActive = true
		
		bottomAnchorConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
		bottomAnchorConstraint.isActive = true
		
		minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
		
		NSLayoutConstraint.activate([
			playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
	}

	
	@objc public func minimizePlayer() {
		maximizedTopAnchorConstraint.isActive = false
		bottomAnchorConstraint.constant = view.frame.height
		minimizedTopAnchorConstraint.isActive = true
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.view.layoutIfNeeded()
			self.playerDetailsView.maximizedStackView.alpha = 0
			self.playerDetailsView.miniPlayerView.alpha = 1
		})
		self.tabBar.transform = .identity
	}
	
	
	public func maximizePlayer(episode: Episode?, playlist: [Episode]? = nil) {
		minimizedTopAnchorConstraint.isActive = false
		maximizedTopAnchorConstraint.isActive = true
		maximizedTopAnchorConstraint.constant = 0
		bottomAnchorConstraint.constant = 0
		
		if let playlist = playlist {
			playerDetailsView.playlist = playlist
		}
		
		if episode != nil {
			playerDetailsView.episode = episode
		}
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.view.layoutIfNeeded()
			self.playerDetailsView.maximizedStackView.alpha = 1
			self.playerDetailsView.miniPlayerView.alpha = 0
		})
		self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100) // hide tabBar
	}
	
	
	private func setupTabs() {
		let favVC = FavoritesController(collectionViewLayout: UICollectionViewFlowLayout())
		viewControllers = [
			createNavController(rootVC: PSearchController(), title: "Поиск", img: #imageLiteral(resourceName: "search")),
			createNavController(rootVC: favVC, title: "Любимые", img: #imageLiteral(resourceName: "favorites")),
			createNavController(rootVC: DownloadsController(), title: "Загрузки", img: #imageLiteral(resourceName: "downloads")),
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
