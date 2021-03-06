//
//  FavoritesController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 11.06.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit
import AXPhotoViewer
import SDWebImage
//import FLAnimatedImage



class FavoritesController: UICollectionViewController, SomeM {

	private var favPodcastsArr = UserDefaults.standard.fetchFavorites()
	private var placeholder: PlaceholderView!
	private var selectedIndexArr = [IndexPath]() // selected cell Index array
	private var lastSelectedCell = IndexPath()
	private var panGesture: UIPanGestureRecognizer!
	private var isImagePreview: Bool {
		get {
			let flag = UserDefaults.standard.value(forKey: SettingsBundleHelper.PREVIEW_IMAGE)
			if let flag = flag as? Bool  {
				return flag
			}
			return false
		}
	}
	public var savedIndexPath = IndexPath(item: 0, section: 0)
	private let editStr = "Edit".localized
	private let deleteStr = "Delete".localized
	private let cancelStr = "Cancel".localized
	


	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupEmty()
		setupCollectionView()
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: editStr, style: .plain, target: self, action: #selector(onEditClick))
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: deleteStr, style: .plain, target: self, action: #selector(onDeleteClick))
		navigationItem.leftBarButtonItem?.isEnabled = false
		panGesture.delegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		/*
		  fixing Swift BUG:
		  you can't select or deselect cell if it was selected before reload
		  you should use both selection methods to do it clickable!
		*/
		if isEditing {
			selectedIndexArr.forEach {
				(indexPath) in
				collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
			}
		}
		guard let bageValue = UIApplication.tabBarVC()?.viewControllers?[1].tabBarItem.badgeValue else { return }
		guard Int(bageValue) != nil else { return }
		if isEditing { // turnOff edit mode
			onEditClick()
		}
		favPodcastsArr = UserDefaults.standard.fetchFavorites()
		collectionView.reloadData()
		UIApplication.tabBarVC()?.viewControllers?[1].tabBarItem.badgeValue = nil
		//collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
		//collectionView.collectionViewLayout.invalidateLayout()
		//collectionView.layoutSubviews()
	}
	
	
	// does not work properly
	override var shouldAutorotate: Bool {
		return true
	}
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}
//	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//		coordinator.animate(alongsideTransition: nil, completion:
//			{_ in
//				UIView.setAnimationsEnabled(true)
//		})
//		UIView.setAnimationsEnabled(false)
//		super.viewWillTransition(to: size, with: coordinator)
//	}
	
	
	private func setupCollectionView() {
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.allowsMultipleSelection = true
		collectionView.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: FavoritePodcastCell.favCellIdentifier)
		collectionView.alwaysBounceVertical = true
		collectionView.backgroundColor = .white
		
		// for pangesture selection cells
		collectionView.canCancelContentTouches = false
		panGesture = UIPanGestureRecognizer(target: self, action: #selector(didHorizontalPan(gesture:)))
		collectionView.addGestureRecognizer(panGesture)
		panGesture.isEnabled = false
		
		let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
		collectionView.addGestureRecognizer(longGesture)
		
		// 3d Touch register
		if traitCollection.forceTouchCapability == .available {
			registerForPreviewing(with: self, sourceView: collectionView)
			longGesture.isEnabled = false
		}
	}
	
	
	@objc private func onEditClick() {
		guard let button = navigationItem.rightBarButtonItem else { return }
		isEditing = !isEditing
		if isEditing {
			button.title = cancelStr
			panGesture.isEnabled = true
		}
		else {
			panGesture.isEnabled = false
			button.title = editStr
			navigationItem.leftBarButtonItem?.isEnabled = false
			makeDeselect()
		}
		NotificationCenter.default.post(name: .editModeChahged, object: isEditing)
	}
	
	
	@objc private func onDeleteClick() {
		deleteItems(indexPathArr: selectedIndexArr)
		onEditClick()
	}
	
	// method of protocol SomeM
	func deleteItems(indexPathArr: [IndexPath]) {
		// remove multiple elements from array
		let indexesToDelete = indexPathArr.map{ $0.row }
		let resultArtr = favPodcastsArr
			.enumerated()
			.filter { !indexesToDelete.contains( $0.offset) }
			.map { $0.element }
		favPodcastsArr = resultArtr
		
		collectionView.performBatchUpdates({
			self.collectionView.deleteItems(at: indexPathArr)
			// remove from UserDefaults
			let data = NSKeyedArchiver.archivedData(withRootObject: self.favPodcastsArr)
			UserDefaults.standard.set(data, forKey: "favPodKey")
		}) {
			(_) in
			self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
		}
	}
	
	
	/// configure empty collectionView
	private func setupEmty() {
		placeholder = PlaceholderView(img: #imageLiteral(resourceName: "placeholder_favorites"), title: "No records".localized, onTapAction: {
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
		
		let actionSheetVC = UIAlertController(title: "Actions".localized, message: nil, preferredStyle: .actionSheet)
		let delAction = UIAlertAction(title: deleteStr, style: .destructive) {
			(action) in
			self.deleteItems(indexPathArr: [indexPath])
			self.animateWithBlur(needBlur: false)
		}
		let cancelAction = UIAlertAction(title: cancelStr, style: .cancel) {
			_ in
			self.animateWithBlur(needBlur: false)
		}
		let previewAction = UIAlertAction(title: "Preview album artwork".localized, style: .default) {
			(_) in
			let previewController = self.getPreviewController(indexPath: indexPath)
			self.animateWithBlur(needBlur: false)
			self.present(previewController, animated: true)
		}
		actionSheetVC.addAction(previewAction)
		actionSheetVC.addAction(delAction)
		actionSheetVC.addAction(cancelAction)
		
		// for iPad only
		if (UIDevice.current.userInterfaceIdiom == .pad) {
			if let popoverController = actionSheetVC.popoverPresentationController {
				popoverController.sourceView = view
				popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
				popoverController.delegate = self
				popoverController.permittedArrowDirections = [] // remove menu arrow
			}
		}
		animateWithBlur(needBlur: true)
		present(actionSheetVC, animated: true)
	}
	
	var effect: CustomIntensityVisualEffectView!
	
	private func animateWithBlur(needBlur: Bool) {
		if needBlur {
			let blurFilter = UIBlurEffect(style: UIBlurEffect.Style.dark)
			effect = CustomIntensityVisualEffectView (effect: blurFilter, intensity: 0.15)
			effect.frame = view.bounds
			effect.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			view.addSubview(effect)
		}
		else {
			view.subviews.forEach {
				(subview) in
				if subview is UIVisualEffectView {
					subview.removeFromSuperview()
				}
			}
		}
	}
	
	
	
	/// Append or delete element if array allready has element
	private func pushElement(indexPath: IndexPath) {
		if let index = selectedIndexArr.firstIndex(of: indexPath) {
			selectedIndexArr.remove(at: index)
			if selectedIndexArr.isEmpty {
				navigationItem.leftBarButtonItem?.isEnabled = false
			}
			return
		}
		selectedIndexArr.append(indexPath)
		if !selectedIndexArr.isEmpty {
			navigationItem.leftBarButtonItem?.isEnabled = true
		}
	}
	
	
	private func makeDeselect() {
		print(selectedIndexArr)
		let copy = selectedIndexArr
		selectedIndexArr.removeAll()
		copy.forEach {
			(indexPath) in
			collectionView.deselectItem(at: indexPath, animated: false)
		}
	}
	

	/// open AXPhotosViewController
	private func getPreviewController(indexPath: IndexPath) -> AXPhotosViewControllerCustom {
		let cell = collectionView.cellForItem(at: indexPath) as! FavoritePodcastCell
		let imageView = cell.imageView
		let transitionInfo = AXTransitionInfo(interactiveDismissalEnabled: true, startingView: imageView) {
			[weak self] (photo, index) -> UIImageView? in
			guard let `self` = self else {
				return nil
			}
			let indexPath = IndexPath(row: index, section: 0)
			guard let lastViewedCell = self.collectionView.cellForItem(at: indexPath) as? FavoritePodcastCell else {
				return nil
			}
			// adjusting the reference view attached to our transition info to allow for contextual animation
			return lastViewedCell.imageView
		}
		let dataSource = AXPhotosDataSource(photos: favPodcastsArr, initialPhotoIndex: indexPath.item)
		let photosViewController = AXPhotosViewControllerCustom(dataSource: dataSource, pagingConfig: nil, transitionInfo: transitionInfo)
		photosViewController.delegate = self
		
		//bottomBar customisation
		// --------
//		let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//		let bottomView = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 44)))
//		let customView = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 20)))
//		customView.text = "\(photosViewController.currentPhotoIndex + 1)"
//		customView.textColor = .white
//		customView.sizeToFit()
//		bottomView.items = [
//			UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil),
//			flex,
//			UIBarButtonItem(customView: customView),
//			flex,
//			UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil),
//		]
//		bottomView.backgroundColor = .clear
//		bottomView.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
//		photosViewController.overlayView.bottomStackContainer.insertSubview(bottomView, at: 0)
		// --------
		return photosViewController
	}
	
	
	//MARK:- UICollectionView methods
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
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
		cell.configure(passedPodcast: favPodcastsArr[indexPath.row], hasSelection: hasSelection, indexPath: indexPath)
		return cell
	}
	
	
	/// This method sometime is not registering touches!!!
//	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//	}
	
//	override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//		if isEditing {
//			pushElement(indexPath: indexPath)
//		}
//	}
	
}


// display popover (menu) in full screen
extension FavoritesController: UIPopoverPresentationControllerDelegate {
	func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}
}


extension FavoritesController: FavoritesControllerDelegate {
	
	func didSelectItemAt(indexPath: IndexPath) {
		let selectedItem = favPodcastsArr[indexPath.item]
		// select/deselect
		if isEditing {
			guard let cell = collectionView.cellForItem(at: indexPath) else { return }
			if cell.isSelected {
				collectionView.deselectItem(at: indexPath, animated: false)
			}
			else {
				collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
			}
			pushElement(indexPath: indexPath)
			return
		}
		// preview
		if isImagePreview {
			let previewController = getPreviewController(indexPath: indexPath)
			previewController.presentAboveAll()
			//present(previewController, animated: true)
		}
		// start play
		else {
			let episodesVC = EpisodesController()
			episodesVC.podcast = selectedItem
			navigationController?.pushViewController(episodesVC, animated: true)
		}
	}
	
	func currentEditStatus() -> Bool {
		return isEditing
	}
}



// Force touch implementation
extension FavoritesController: AXPhotosViewControllerDelegate, UIViewControllerPreviewingDelegate {
	
	// fire on 1-st force touch
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		guard let indexPath = collectionView.indexPathForItem(at: location),
			let cell = collectionView.cellForItem(at: indexPath) as? FavoritePodcastCell else {
				return nil
		}
		savedIndexPath = indexPath
		let imageView = cell.imageView
		previewingContext.sourceRect = self.collectionView.convert(imageView.frame, from: imageView.superview)
		let dataSource = AXPhotosDataSource(photos: favPodcastsArr, initialPhotoIndex: indexPath.row)
		let previewingPhotosViewController = AXPreviewingPhotosViewControllerM(dataSource: dataSource)
		previewingPhotosViewController.delegate = self
		return previewingPhotosViewController
	}
	
	// fire on 2-nd force touch
	func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		guard viewControllerToCommit is AXPreviewingPhotosViewControllerM  else { return }
		let previewController: AXPhotosViewControllerCustom = getPreviewController(indexPath: savedIndexPath)
		present(previewController, animated: false)
	}
	
}


/// cells sizing
extension FavoritesController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var needWidth = (view.frame.width - 3 * 16) / 2
		if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
			needWidth = (view.frame.width - 5 * 16) / 3
		}
		return CGSize(width: needWidth, height: needWidth + 40) // 40 - footer height for labels
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 16
	}
}


/// for cells selection via pangesture (horizontal swipe)
extension FavoritesController: UIGestureRecognizerDelegate {
	
	// allow recognition of two gestures at the same time
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
	@objc private func didHorizontalPan(gesture: UIPanGestureRecognizer) {
		let velocity = panGesture.velocity(in: collectionView)
		// pass only horizontal gestures
		if abs(velocity.y) < abs(velocity.x) {
			didPanToSelectCells(panGesture: gesture)
		}
	}
	
	
	private func didPanToSelectCells(panGesture: UIPanGestureRecognizer) {
		guard isEditing else { return }
		switch panGesture.state {
		case .began:
			collectionView.isScrollEnabled = false
		case .changed:
			let location: CGPoint = panGesture.location(in: collectionView)
			if let indexPath: IndexPath = collectionView?.indexPathForItem(at: location) {
				if indexPath != lastSelectedCell { // fix blinking on touched cell
					selectCell(indexPath, selected: true)
					lastSelectedCell = indexPath
				}
			}
		case .ended, .failed, .cancelled, .possible:
			collectionView.isScrollEnabled = true
		}
	}
	
	
	private func selectCell(_ indexPath: IndexPath, selected: Bool) {
		if let cell = collectionView.cellForItem(at: indexPath) {
			if cell.isSelected {
				collectionView.deselectItem(at: indexPath, animated: true)
				// automatic scroll-down after selection
				//collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredVertically,
					//						animated: true)
			}
			else {
				collectionView.selectItem(at: indexPath, animated: true, scrollPosition: []) // .centeredVertically
			}
			pushElement(indexPath: indexPath)
		}
	}
	
}

protocol SomeM: class {
	func deleteItems(indexPathArr: [IndexPath])
	var savedIndexPath: IndexPath { get set }
}


class AXPreviewingPhotosViewControllerM: AXPreviewingPhotosViewController {
	
	weak var delegate: SomeM?
	
	open override var previewActionItems: [UIPreviewActionItem] {
		let deleteAction = UIPreviewAction(title: "Delete".localized, style: .destructive) {
			(action, viewController) -> Void in

			guard let safeDelegate = self.delegate else { return }
			safeDelegate.deleteItems(indexPathArr: [safeDelegate.savedIndexPath])
		}
		let cancelAction = UIPreviewAction(title: "Cancel".localized, style: .default) {
			(action, viewController) -> Void in
		}
		return [deleteAction, cancelAction] // cancelAction will be bottom
	}
	
}


class AXPhotosViewControllerCustom: AXPhotosViewController, Rotatable {
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		//if isMovingFromParent {
			resetToPortrait()
		//}
	}
	
//	override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
//		<#code#>
//	}
	
}
