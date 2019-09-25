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


class PurchaseDetailController: UIViewController {
	
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
	private let scrollView = UIScrollView()
	private var purchModel: PurchModel!
	private var skProduct: SKProduct!
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
		
		installLayout()
		installConstraints()
	}
	
	
	private func installLayout() {
		// buyButton
		buyButton.setTitle(skProduct.localizedPrice, for: .normal)
		let rButton = UIBarButtonItem(customView: buyButton)
		navigationItem.rightBarButtonItem = rButton
		buyButton.addTarget(self, action: #selector(onBuyClick), for: .touchUpInside)
		
		// scrollView
		scrollView.alwaysBounceVertical = true
		view.addSubview(scrollView)
		scrollView.fillSuperView()
		
		// productImg & descriptionText
		if let url = URL(string: purchModel.imageURL) {
			productImg.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: [])
		}
		descriptionText.text = purchModel.descript_long.ru
		
		// size label
		sizeLabel.text = getConvertedSize()
		
		scrollView.addSubview(productImg)
		scrollView.addSubview(descriptionText)
		scrollView.addSubview(sizeLabel)
	}
	
	
	private func installConstraints() {
		NSLayoutConstraint.activate([
			buyButton.heightAnchor.constraint(equalToConstant: 28),
			buyButton.widthAnchor.constraint(equalToConstant: 60),
			scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			productImg.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 5),
			productImg.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 5),
			productImg.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
			productImg.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 10),
			descriptionText.topAnchor.constraint(equalTo: productImg.bottomAnchor, constant: 15),
			descriptionText.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
			descriptionText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			sizeLabel.topAnchor.constraint(equalTo: descriptionText.bottomAnchor, constant: 15),
			sizeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35),
		])
	}
	
	
	@objc private func onBuyClick() {
		IAPManager.shared.purchaseProduct(productID: productID)
		HUD.flash(.progress, onView: nil, delay: 2, completion: nil)
	}
	
	
	private func setContentHeight() {
		var contentRect = CGRect.zero
		scrollView.subviews.forEach {
			(subview) in
			contentRect = contentRect.union(subview.frame)
		}
		let blankIntervalsSumm: CGFloat = 35
		let finalSize = CGSize(width: contentRect.width, height: contentRect.height + blankIntervalsSumm)
		scrollView.contentSize = finalSize
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
