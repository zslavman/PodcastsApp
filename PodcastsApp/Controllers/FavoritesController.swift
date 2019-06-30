//
//  FavoritesController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 11.06.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

class FavoritesController: UICollectionViewController  {
	
	private var favPodcastsArr = UserDefaults.standard.fetchFavorites()
	private lazy var placeholder = PlaceholderView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupEmty()
		setupCollectionView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		favPodcastsArr = UserDefaults.standard.fetchFavorites()
		collectionView.reloadData()
		UIApplication.tabBarVC()?.viewControllers?[1].tabBarItem.badgeValue = nil
	}
	
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
			UIApplication.tabBarVC()?.setTabBar(hidden: true)
		}
		else {
			UIApplication.tabBarVC()?.setTabBar(hidden: false)
		}
	}
	
	private func setupCollectionView() {
		collectionView.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: FavoritePodcastCell.favCellIdentifier)
		collectionView.alwaysBounceVertical = true
		collectionView.backgroundColor = .white
		
		let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
		collectionView.addGestureRecognizer(longGesture)
	}
	
	
	/// configure empty collectionView
	private func setupEmty() {
		placeholder = PlaceholderView(img: #imageLiteral(resourceName: "placeholder_favorites"), title: "Нет записей", onTapAction: {
			self.tabBarController?.selectedIndex = 0
		})
		collectionView.addSubview(placeholder)
	}
	
	
	@objc private func onPlaceholderTap() {
		tabBarController?.selectedIndex = 0
		print("1 tap")
	}
	
	
	@objc private func onLongPress(gesture: UIGestureRecognizer) {
		guard gesture.state == .began else { return }
		let touchLocation = gesture.location(in: collectionView)
		guard let indexPath = collectionView.indexPathForItem(at: touchLocation) else { return }
		SUtils.tapticFeedback()
		
		let actionSheetVC = UIAlertController(title: "Действия с подкастом", message: nil, preferredStyle: .actionSheet)
		let delAction = UIAlertAction(title: "Удалить", style: .destructive) {
			(action) in
			self.favPodcastsArr.remove(at: indexPath.row)
			self.collectionView.deleteItems(at: [indexPath])
			// remove from UserDefaults
			let data = NSKeyedArchiver.archivedData(withRootObject: self.favPodcastsArr)
			UserDefaults.standard.set(data, forKey: "favPodKey")
		}
		let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
		
		actionSheetVC.addAction(delAction)
		actionSheetVC.addAction(cancelAction)
		present(actionSheetVC, animated: true)
	}
	
	
	//MARK:- UICollectionView methods
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if favPodcastsArr.count == 0 {
			placeholder.isHidden = false
		}
		else {
			placeholder.isHidden = true
		}
		return favPodcastsArr.count
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritePodcastCell.favCellIdentifier, for: indexPath) as! FavoritePodcastCell
		cell.configure(passedPodcast: favPodcastsArr[indexPath.row])
		return cell
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let episodesVC = EpisodesController()
		episodesVC.podcast = favPodcastsArr[indexPath.item]
		navigationController?.pushViewController(episodesVC, animated: true)
	}
	
}


/// sizing of cells
extension FavoritesController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let needWidth = (view.frame.width - 3 * 16) / 2
		return CGSize(width: needWidth, height: needWidth + 40)// 40 - footer height for labels
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 16
	}
}


