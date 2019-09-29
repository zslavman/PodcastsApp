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
		installLayout()
		installConstraints()
		checkBuyStatus()
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		setContentHeight()
	}
	
	
//	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//		return .portrait
//	}
//	override var shouldAutorotate: Bool {
//		return false
//	}
	
	public func initWith(productID: String) {
		self.productID = productID
		guard let purchModel = (JSONDownloadService.shared.parsed.filter{ $0.purchaseID == productID }).first,
		let skProduct = (IAPManager.shared.availablePurchases.filter{ $0.productIdentifier == productID }).first
			else { return }
		self.purchModel = purchModel
		self.skProduct = skProduct
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
			//TODO: check if already bought, if need update
		}
	}
	
	
	private func installLayout() {
		collectionView.alwaysBounceVertical = true
		
		// buyButton
		buyButton.setTitle(skProduct.localizedPrice, for: .normal)
		let rButton = UIBarButtonItem(customView: buyButton)
		navigationItem.rightBarButtonItem = rButton
		buyButton.addTarget(self, action: #selector(onBuyClick), for: .touchUpInside)
		buyButton.addSubview(activityIndicator)

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
		sizeDescriptStack.heightAnchor.constraint(equalToConstant: 300).isActive = true
		
		let bars = UIScreen.main.bounds.height - (navigationController?.navigationBar.frame.height ?? 44) - 49
		let picWidth = min(UIScreen.main.bounds.width - 10, bars)
		productImg.widthAnchor.constraint(equalToConstant: picWidth).isActive = true
		productImg.heightAnchor.constraint(equalTo: productImg.widthAnchor, multiplier: 1).isActive = true
		
		mainVertStackView = UIStackView(arrangedSubviews: [productImg, sizeDescriptStack])
		mainVertStackView.axis = .vertical
		mainVertStackView.spacing = 15
		mainVertStackView.isLayoutMarginsRelativeArrangement = true
		mainVertStackView.layoutMargins = .init(top: 5, left: 5, bottom: 15, right: 5)
		
		collectionView.addSubview(mainVertStackView)
	}

	
	private func installConstraints() {
		NSLayoutConstraint.activate([
			buyButton.heightAnchor.constraint(equalToConstant: 28),
			buyButton.widthAnchor.constraint(equalToConstant: 60),
			activityIndicator.centerXAnchor.constraint(equalTo: buyButton.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: buyButton.centerYAnchor),
			
			descriptionText.heightAnchor.constraint(equalToConstant: 200),
			
			mainVertStackView.topAnchor.constraint(equalTo: collectionView.topAnchor),
			mainVertStackView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
			mainVertStackView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
			mainVertStackView.heightAnchor.constraint(equalToConstant: 1000),

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
		}
		else {
			print("Vertical device position")
		}
	}
	
}
