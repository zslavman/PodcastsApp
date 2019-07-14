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
	private var placeholder: PlaceholderView!
	private var selectedIndexArr = [IndexPath]() // This is selected cell Index array
	private var selectedDataArr = [Podcast]() // This is selected cell data array
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupEmty()
		setupCollectionView()
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Редакт", style: .plain, target: self, action: #selector(onEditClick))
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Удалить", style: .plain, target: self, action: #selector(onDeleteClick))
		navigationItem.leftBarButtonItem?.isEnabled = false
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		collectionView.performBatchUpdates({
//			favPodcastsArr = UserDefaults.standard.fetchFavorites()
//			collectionView.reloadData()
		})
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
		collectionView.allowsMultipleSelection = true
		collectionView.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: FavoritePodcastCell.favCellIdentifier)
		collectionView.alwaysBounceVertical = true
		collectionView.backgroundColor = .white
		
		let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
		collectionView.addGestureRecognizer(longGesture)
	}
	
	@objc private func onEditClick() {
		guard let button = navigationItem.rightBarButtonItem else { return }
		isEditing = !isEditing
		if isEditing {
			button.title = "Отмена"
			navigationItem.leftBarButtonItem?.isEnabled = true
		}
		else {
			button.title = "Редакт."
			navigationItem.leftBarButtonItem?.isEnabled = false
			makeDeselect()
		}
		NotificationCenter.default.post(name: .editModeChahged, object: isEditing)
	}
	
	@objc private func onDeleteClick() {
		
	}
	
	
	/// configure empty collectionView
	private func setupEmty() {
		placeholder = PlaceholderView(img: #imageLiteral(resourceName: "placeholder_favorites"), title: "Нет записей", onTapAction: {
			guard let toView = UIApplication.tabBarVC()?.viewControllers?.first?.view else { return }
			UIView.transition(from: self.view, to: toView, duration: 0.4, options: [.transitionCrossDissolve], completion: {
				(bool) in
				self.tabBarController?.selectedIndex = 0
			})
		})
		view.addSubview(placeholder)
	}
	
	
	@objc private func onLongPress(gesture: UIGestureRecognizer) {
		if isEditing { return }
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
	
	
	/// Append or delete element if array allready has element
	private func pushElement(indexPath: IndexPath) {
		if let index = selectedIndexArr.firstIndex(of: indexPath) {
			selectedIndexArr.remove(at: index)
			return
		}
		selectedIndexArr.append(indexPath)
	}
	
	
	private func makeDeselect() {
		print(selectedIndexArr)
		selectedIndexArr.forEach {
			(indexPath) in
			collectionView.deselectItem(at: indexPath, animated: false)
		}
		selectedIndexArr.removeAll()
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
		cell.delegate = self
		let hasSelection = selectedIndexArr.contains(indexPath)
		cell.configure(passedPodcast: favPodcastsArr[indexPath.row], hasSelection: hasSelection)
		return cell
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let selectedItem = favPodcastsArr[indexPath.item]
		if isEditing {
			pushElement(indexPath: indexPath)
			return
		}
		let episodesVC = EpisodesController()
		episodesVC.podcast = selectedItem
		navigationController?.pushViewController(episodesVC, animated: true)
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		if isEditing {
			pushElement(indexPath: indexPath)
		}
	}
	
	
}


extension FavoritesController: FavoritesControllerDelegate {
	func currentEditStatus() -> Bool {
		return isEditing
	}
}

/// cells sizing
extension FavoritesController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let needWidth = (view.frame.width - 3 * 16) / 2
		return CGSize(width: needWidth, height: needWidth + 40) // 40 - footer height for labels
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 16
	}
}


