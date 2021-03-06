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
		//UINavigationBar.appearance().prefersLargeTitles = true
		setupTabs()
		setupPlayerDetailsView()
		NotificationCenter.default.addObserver(self, selector: #selector(onLoadComplete), name: .downloadComplete, object: nil)
	}
	
	
	/// update badge on last tab when download complete
	@objc private func onLoadComplete(notif: Notification) {
		let badgeValue = viewControllers?[2].tabBarItem.badgeValue
		guard let bv = badgeValue, var intFromString = Int(bv) else { return }
		DispatchQueue.main.async {
			if intFromString <= 1 {
				self.viewControllers?[2].tabBarItem.badgeValue = nil
			}
			else {
				intFromString -= 1
				self.viewControllers?[2].tabBarItem.badgeValue = intFromString.description
			}
		}
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
	
	
	public func prepareConstraintToMinimize() {
//		maximizedTopAnchorConstraint.isActive = false
//		bottomAnchorConstraint.constant = view.frame.height
//		minimizedTopAnchorConstraint.isActive = true
	}
	

	@objc public func minimizePlayer() {
		maximizedTopAnchorConstraint.isActive = false
		bottomAnchorConstraint.constant = view.frame.height
		minimizedTopAnchorConstraint.isActive = true
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.view.layoutIfNeeded()
			self.playerDetailsView.maximizedStackView.alpha = 0
			self.playerDetailsView.miniPlayerView.alpha = 1
		}, completion: {
			(_) in
			self.playerDetailsView.isMinimized = true
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
			playerDetailsView.episode = episode // start playing
		}
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.view.layoutIfNeeded()
			self.playerDetailsView.maximizedStackView.alpha = 1
			self.playerDetailsView.miniPlayerView.alpha = 0
		}, completion: {
			(_) in
			self.playerDetailsView.isMinimized = false
		})
		tabBar.transform = CGAffineTransform(translationX: 0, y: 100) // hide tabBar
	}
	
	
	public func hideMiniPlayer() {
		maximizedTopAnchorConstraint.constant = view.frame.height
		maximizedTopAnchorConstraint.isActive = true
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
	}
	
	
	
	private func setupTabs() {
		let favVC = FavoritesController(collectionViewLayout: UICollectionViewFlowLayout())
		viewControllers = [
			//createNavController(rootVC: PurchasesController(), title: "Test", img: #imageLiteral(resourceName: "downloads")),
			createNavController(rootVC: PSearchController(), title: "Search".localized, img: #imageLiteral(resourceName: "search")),
			createNavController(rootVC: favVC, title: "Favorites".localized, img: #imageLiteral(resourceName: "favorites")),
			createNavController(rootVC: DownloadsController(), title: "Downloads".localized, img: #imageLiteral(resourceName: "downloads")),
		]
	}
	
	
	private func createNavController(rootVC: UIViewController, title: String, img: UIImage) -> UIViewController {
		let navVC = UINavigationController(rootViewController: rootVC)
		navVC.tabBarItem.title = title
		navVC.tabBarItem.image = img
		rootVC.navigationItem.title = title // title on top of VC
		return navVC
	}
	
	
	/// hide/show tabbar
	func setTabBar(hidden: Bool) {
//		var offset: CGFloat = UIScreen.main.bounds.size.height
//		if hidden {
//			holdOnSafeArea()
//		} else {
//			holdOnTabBar()
//			offset = UIScreen.main.bounds.size.height - tabBar.frame.size.height
//		}
//		if offset == tabBar.frame.origin.y { return }
//		UIView.animate(withDuration: 0.3, animations: {
//			self.tabBar.frame.origin.y = offset
//		})
	}
	
	
	public func holdOnSafeArea() {
		minimizedTopAnchorConstraint.isActive = false
		minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -64)
		minimizedTopAnchorConstraint.isActive = true
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
	}
	
	public func holdOnTabBar() {
		minimizedTopAnchorConstraint.isActive = false
		minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
		minimizedTopAnchorConstraint.isActive = true
	}
	
}
