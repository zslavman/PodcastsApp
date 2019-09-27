//
//  PurchaseDetailController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 24.09.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit
import PKHUD
import StoreKit
import MaterialComponents.MaterialActivityIndicator


class PurchaseDetailController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	
	private var productID: String!
	private let productImg: UIImageView = {
		let img = UIImageView()
		img.translatesAutoresizingMaskIntoConstraints = false
		img.contentMode = .scaleAspectFill
		img.layer.cornerRadius = 8
		img.clipsToBounds = true
		return img
	}()
	private let descriptionText: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
		label.numberOfLines = 0
		return label
	}()
	private let sizeLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
		label.textColor = #colorLiteral(red: 0.6614649429, green: 0.6614649429, blue: 0.6614649429, alpha: 1)
		label.textAlignment = .right
		return label
	}()
	private let buyButton: UIButton = {
		let bttn = UIButton(type: .system)
		bttn.translatesAutoresizingMaskIntoConstraints = false
		bttn.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
		bttn.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		bttn.layer.cornerRadius = 5
		bttn.clipsToBounds = true
		bttn.titleLabel?.numberOfLines = 1
		bttn.titleLabel?.adjustsFontSizeToFitWidth = true
		bttn.titleLabel?.lineBreakMode = .byClipping
		bttn.titleLabel?.baselineAdjustment = .alignCenters
		bttn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		return bttn
	}()
	private let activityIndicator: MDCActivityIndicator = {
		let ind = MDCActivityIndicator()
		ind.translatesAutoresizingMaskIntoConstraints = false
		ind.sizeToFit()
		ind.indicatorMode = .indeterminate
		ind.cycleColors = [UIColor.white.withAlphaComponent(1)]
		ind.radius = 8
		ind.strokeWidth = 1.5
		ind.isHidden = true
		return ind
	}()
	private var purchModel: PurchModel!
	private var skProduct: SKProduct!
	private var mainVertStackView: UIStackView!
	private var scroll: UIScrollView!
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		collectionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		navigationItem.title = purchModel.title.ru
		NotificationCenter.default.addObserver(self, selector: #selector(purchaseDidChangeStatus(notif:)),
											   name: .purchaseDownloadingCompleted, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(purchaseDidChangeStatus(notif:)),
											   name: .purchaseDownloadingError, object: nil)
		checkBuyStatus()
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		//setContentHeight()
		
//		let contentViewHeight = scroll.contentSize.height + 200 + 20
//		let offsetY = contentViewHeight - scroll.bounds.height
//		if (offsetY > 0) {
//			//scroll.setContentOffset(CGPoint(x: scroll.contentOffset.x, y: offsetY), animated: true)
//			scroll.contentSize = CGSize(width: 20, height: offsetY)
//		}
	}
	
	
	public func initWith(productID: String) {
		self.productID = productID
		guard let purchModel = (JSONDownloadService.shared.parsed.filter{ $0.purchaseID == productID }).first,
		let skProduct = (IAPManager.shared.availablePurchases.filter{ $0.productIdentifier == productID }).first
			else { return }
		self.purchModel = purchModel
		self.skProduct = skProduct
		
		installBuyBttnWithActivity()
		
		installLayout2()
	}
	
	
	/// purchase did change status notification observer
	@objc private func purchaseDidChangeStatus(notif: Notification) {
		var purchID: String?
		if let comleteID = notif.object as? String {
			purchID = comleteID
		}
		else if let errorEntity = notif.object as? PurchaseErrorEntity {
			purchID = errorEntity.purchaseID
		}
		guard let safeID = purchID, safeID == purchModel.purchaseID else { return }
		setActivityIndicator(isActive: false)
	}
	
	
	private func checkBuyStatus() {
		if IAPManager.shared.suspendedPurchaseIDs.contains(purchModel.purchaseID) {
			setActivityIndicator(isActive: true)
		}
		else {
			//TODO: check if already buy, if need update
		}
	}
	
	
	
	private func installBuyBttnWithActivity() {
		// buyButton
		buyButton.setTitle(skProduct.localizedPrice, for: .normal)
		let rButton = UIBarButtonItem(customView: buyButton)
		navigationItem.rightBarButtonItem = rButton
		buyButton.addTarget(self, action: #selector(onBuyClick), for: .touchUpInside)
		
		buyButton.addSubview(activityIndicator)
		
		NSLayoutConstraint.activate([
			buyButton.heightAnchor.constraint(equalToConstant: 28),
			buyButton.widthAnchor.constraint(equalToConstant: 60),
			activityIndicator.centerXAnchor.constraint(equalTo: buyButton.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: buyButton.centerYAnchor),
		])
	}
	
	
	
	private func installLayout() {
		collectionView.alwaysBounceVertical = true

		// productImg & descriptionText
		if let url = URL(string: purchModel.imageURL) {
			productImg.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: [])
		}
		descriptionText.text = purchModel.descript_long.ru
		
		// size label
		sizeLabel.text = getConvertedSize()
		
		let sizeDescriptStack = UIStackView(arrangedSubviews: [descriptionText, sizeLabel])
		sizeDescriptStack.axis = .vertical
		sizeDescriptStack.spacing = 15
		//sizeDescriptStack.distribution = .fill
		
		mainVertStackView = UIStackView(arrangedSubviews: [productImg, sizeDescriptStack])
		mainVertStackView.axis = .vertical
		mainVertStackView.spacing = 15
		mainVertStackView.isLayoutMarginsRelativeArrangement = true
		mainVertStackView.layoutMargins = .init(top: 5, left: 5, bottom: 15, right: 5)
		//mainVertStackView.distribution = .fill
		
		collectionView.addSubview(mainVertStackView)
	}
	
	
	private func installLayout2() {
		scroll = UIScrollView()
		scroll.translatesAutoresizingMaskIntoConstraints = false
		scroll.alwaysBounceVertical = true
		view.addSubview(scroll)
		scroll.fillSuperView()
		
		let p1 = UIView()
		p1.translatesAutoresizingMaskIntoConstraints = false
		p1.backgroundColor = .red
		p1.heightAnchor.constraint(equalToConstant: 200).isActive = true
		p1.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 10).isActive = true
		
		let p2 = UIView()
		p2.translatesAutoresizingMaskIntoConstraints = false
		p2.backgroundColor = .green
		p2.heightAnchor.constraint(equalToConstant: 1900).isActive = true
		
		let p3 = UIView()
		p3.translatesAutoresizingMaskIntoConstraints = false
		p3.backgroundColor = .blue
		p3.heightAnchor.constraint(equalToConstant: 500).isActive = true
		
		mainVertStackView = UIStackView(arrangedSubviews: [p1, p2, p3])
		mainVertStackView.translatesAutoresizingMaskIntoConstraints = false
		mainVertStackView.axis = .vertical
		mainVertStackView.spacing = 15
		mainVertStackView.isLayoutMarginsRelativeArrangement = true
		mainVertStackView.layoutMargins = .init(top: 5, left: 5, bottom: 5, right: 5)
		
		scroll.addSubview(mainVertStackView)
	
		NSLayoutConstraint.activate([
			mainVertStackView.topAnchor.constraint(equalTo: scroll.topAnchor),
			mainVertStackView.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
			mainVertStackView.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
			mainVertStackView.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
			//mainVertStackView.heightAnchor.constraint(greaterThanOrEqualTo: scroll.heightAnchor),
		])
		
	}
	
	
	private func installConstraints() {
		NSLayoutConstraint.activate([
			buyButton.heightAnchor.constraint(equalToConstant: 28),
			buyButton.widthAnchor.constraint(equalToConstant: 60),
			
			descriptionText.heightAnchor.constraint(equalToConstant: 200),
			
			mainVertStackView.topAnchor.constraint(equalTo: collectionView.topAnchor),
			mainVertStackView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
			mainVertStackView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
			
			productImg.heightAnchor.constraint(equalToConstant: 280),
			productImg.widthAnchor.constraint(equalToConstant: 280),

			sizeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35),
		])
	}
	
	
	@objc private func onBuyClick() {
		IAPManager.shared.purchaseProduct(productID: productID)
		//HUD.flash(.progress, onView: nil, delay: 2, completion: nil)
		setActivityIndicator(isActive: true)
	}
	
	
	private func setActivityIndicator(isActive: Bool) {
		if isActive {
			buyButton.isEnabled = false
			activityIndicator.isHidden = false
			activityIndicator.startAnimating()
		}
		else {
			buyButton.isEnabled = true
			activityIndicator.isHidden = true
			activityIndicator.stopAnimating()
		}
	}
	
	
	private func setContentHeight() {
		var contentRect = CGRect.zero
		collectionView.subviews.forEach {
			(subview) in
			contentRect = contentRect.union(subview.frame)
		}
		let blankIntervalsSumm: CGFloat = 35
		let finalSize = CGSize(width: contentRect.width, height: contentRect.height + blankIntervalsSumm)
		collectionView.contentSize = finalSize
	}
	
	
	private func getConvertedSize() -> String {
		guard let wholeSizeNumber = skProduct.downloadContentLengths.first else { return "" }
		let fileSizeInt = wholeSizeNumber.int64Value
		let formatter = ByteCountFormatter()
		formatter.countStyle = .file
		formatter.allowedUnits = .useMB
		formatter.includesUnit = true
		let formatedSize = formatter.string(fromByteCount: fileSizeInt)
		return "Размер: \(formatedSize)"
	}
	
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		if traitCollection.verticalSizeClass == .compact {
			print("Hotizontal device position")
			mainVertStackView.axis = .horizontal
		}
		else {
			print("Vertical device position")
			mainVertStackView.axis = .vertical
		}
	}
	
}
