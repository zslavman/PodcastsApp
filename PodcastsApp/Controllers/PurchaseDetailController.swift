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
	private var purchModel: PurchModel!
	private var skProduct: SKProduct!
	private var mainVertStackView: UIStackView!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		collectionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		navigationItem.title = purchModel.title.ru
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		setContentHeight()
	}
	
	
	public func initWith(productID: String) {
		self.productID = productID
		guard let purchModel = (JSONDownloadService.shared.parsed.filter{ $0.purchaseID == productID }).first,
		let skProduct = (IAPManager.shared.availablePurchases.filter{ $0.productIdentifier == productID }).first
			else { return }
		self.purchModel = purchModel
		self.skProduct = skProduct
		
		installLayout2()
		//installConstraints()
	}
	
	
	private func installLayout() {
		collectionView.alwaysBounceVertical = true
		
		// buyButton
		buyButton.setTitle(skProduct.localizedPrice, for: .normal)
		let rButton = UIBarButtonItem(customView: buyButton)
		navigationItem.rightBarButtonItem = rButton
		buyButton.addTarget(self, action: #selector(onBuyClick), for: .touchUpInside)
		
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
		let p1 = UIView()
		p1.backgroundColor = .red
		
		let p2 = UIView()
		p2.backgroundColor = .green
		
		mainVertStackView = UIStackView(arrangedSubviews: [p1, p2])
		mainVertStackView.translatesAutoresizingMaskIntoConstraints = false
		mainVertStackView.axis = .vertical
		mainVertStackView.spacing = 15
		mainVertStackView.isLayoutMarginsRelativeArrangement = true
		mainVertStackView.layoutMargins = .init(top: 5, left: 5, bottom: 5, right: 5)
		mainVertStackView.distribution = .fillEqually
		
		view.addSubview(mainVertStackView)
	
		NSLayoutConstraint.activate([
			mainVertStackView.topAnchor.constraint(equalTo: collectionView.topAnchor),
			mainVertStackView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
			mainVertStackView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
//			mainVertStackView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
//			mainVertStackView.heightAnchor.constraint(equalTo: collectionView.heightAnchor),
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
		HUD.flash(.progress, onView: nil, delay: 2, completion: nil)
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
//		mainVertStackView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: finalSize.height).isActive = true
		mainVertStackView.heightAnchor.constraint(equalToConstant: finalSize.height).isActive = true
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
