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


class PurchaseDetailController: UIViewController {
	
	private var productID: String!
	private let headerView: UIImageView = {
		let img = UIImageView()
		img.translatesAutoresizingMaskIntoConstraints = false
		img.contentMode = .scaleAspectFill
		img.layer.cornerRadius = 8
		img.clipsToBounds = true
		return img
	}()
//	private let descriptionText: UITextView = {
//		let label = UITextView()
//		label.translatesAutoresizingMaskIntoConstraints = false
//		label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//		label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
//		label.isScrollEnabled = false // allow do not set height constraint
//		label.textContainer.lineBreakMode = .byCharWrapping
//		label.sizeToFit()
//		label.textAlignment = .justified
//		label.adjustsFontForContentSizeCategory = true
//		return label
//	}()
	private let descriptionText: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
		label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
		label.lineBreakMode = .byCharWrapping
		label.numberOfLines = 0
		label.textAlignment = .justified // need repeat after set attributed text
		label.adjustsFontForContentSizeCategory = true
		return label
	}()
	private let sizeLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.heavy)
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
	private lazy var scroll: UIScrollView = {
		let scrv = UIScrollView()
		scrv.delegate = self
		scrv.translatesAutoresizingMaskIntoConstraints = false
		scrv.alwaysBounceVertical = true
		return scrv
	}()
	private var purchModel: PurchModel!
	private var skProduct: SKProduct!
	private var mainVertStackView: UIStackView!
	private var headerViewHeight: NSLayoutConstraint?
	private var headerViewWidth: NSLayoutConstraint?
	private var bottomOfheaderView: NSLayoutConstraint?
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		navigationItem.title = purchModel.title.ru
		NotificationCenter.default.addObserver(self, selector: #selector(purchaseDidChangeStatus(notif:)),
											   name: .purchaseDownloadingCompleted, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(purchaseDidChangeStatus(notif:)),
											   name: .purchaseDownloadingError, object: nil)
		installLayout()
		installConstraints()
		checkBuyStatus()
	}
	
	
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
		view.addSubview(scroll)
		
		// buyButton
		buyButton.setTitle(skProduct.localizedPrice, for: .normal)
		let rButton = UIBarButtonItem(customView: buyButton)
		navigationItem.rightBarButtonItem = rButton
		buyButton.addTarget(self, action: #selector(onBuyClick), for: .touchUpInside)
		buyButton.addSubview(activityIndicator)

		// productImg & descriptionText
		if let url = URL(string: purchModel.imageURL) {
			headerView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: [])
		}
		
		// set description text with hyphenation
		setPurchaseDescrition()
		
		// size label
		sizeLabel.text = getConvertedSize()
		
		let sizeAndDescriptStack = UIStackView(arrangedSubviews: [descriptionText, sizeLabel])
		sizeAndDescriptStack.axis = .vertical
		sizeAndDescriptStack.spacing = 15
		sizeAndDescriptStack.isLayoutMarginsRelativeArrangement = true
		sizeAndDescriptStack.layoutMargins = .init(top: 0, left: 15, bottom: 0, right: 15)
		
		let bars = UIScreen.main.bounds.height - (navigationController?.navigationBar.frame.height ?? 44) - 49
		let picWidth = min(UIScreen.main.bounds.width - 10, bars)
		headerView.widthAnchor.constraint(equalToConstant: picWidth).isActive = true
		
		headerViewHeight = headerView.heightAnchor.constraint(equalTo: headerView.widthAnchor)
		headerViewHeight?.isActive = true
		
		mainVertStackView = UIStackView(arrangedSubviews: [headerView, sizeAndDescriptStack])
		mainVertStackView.translatesAutoresizingMaskIntoConstraints = false
		mainVertStackView.axis = .vertical
		mainVertStackView.spacing = 15
		mainVertStackView.isLayoutMarginsRelativeArrangement = true
		mainVertStackView.layoutMargins = .init(top: 5, left: 5, bottom: 15, right: 5)
		
		scroll.addSubview(mainVertStackView)
	}

	
	private func installConstraints() {
		NSLayoutConstraint.activate([
			buyButton.heightAnchor.constraint(equalToConstant: 28),
			buyButton.widthAnchor.constraint(equalToConstant: 60),
			activityIndicator.centerXAnchor.constraint(equalTo: buyButton.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: buyButton.centerYAnchor),
			
			scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			
//			headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
//			headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
//			headerView.centerXAnchor.constraint(equalTo: scroll.centerXAnchor),
			
			mainVertStackView.topAnchor.constraint(equalTo: scroll.topAnchor),
			mainVertStackView.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
			mainVertStackView.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
			mainVertStackView.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
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
	
	
	/// not used
	private func setContentHeight() {
		var contentRect = CGRect.zero
		scroll.subviews.forEach {
			(subview) in
			contentRect = contentRect.union(subview.frame)
		}
		let blankIntervalsSumm: CGFloat = 35
		let finalSize = CGSize(width: contentRect.width, height: contentRect.height + blankIntervalsSumm)
		scroll.contentSize = finalSize
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
	
	
	private func setPurchaseDescrition() {
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.hyphenationFactor = 1
		paragraphStyle.firstLineHeadIndent = 25
		let hyphenAttribute = [NSAttributedString.Key.paragraphStyle : paragraphStyle]
		let attributedString = NSMutableAttributedString(string: purchModel.descript_long.ru, attributes: hyphenAttribute)
		descriptionText.attributedText = attributedString
		descriptionText.textAlignment = .justified
	}
	
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		if traitCollection.verticalSizeClass == .compact {
			print("Hotizontal device position")
		}
		else {
			print("Vertical device position")
		}
	}

	
//	private func stretchPicture() {
//		guard let header = tableHeaderView else { return }
//		guard let imageView = header.subviews.first as? UIImageView else { return }
//
//		headerViewHeight = imageView.constraints.filter{$0.identifier == "picHeight"}.first
//		bottomOfPicture = header.constraints.filter{$0.identifier == "picBottom"}.first
//
//		let offsetY = -contentOffset.y
//		bottomOfPicture?.constant = offsetY >= 0 ? 0 : offsetY / 2
//		header.clipsToBounds = offsetY <= 0 // фикс пробела сверху
//		headerViewHeight?.constant = max(header.bounds.height, header.bounds.height + offsetY)
//	}
	
}


extension PurchaseDetailController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
//		let offsetY = -scrollView.contentOffset.y
		//bottomOfPicture?.constant = offsetY >= 0 ? 0 : offsetY / 2
		//headerView.clipsToBounds = offsetY <= 0 // фикс пробела сверху
//		let delta = max(headerView.bounds.height, headerView.bounds.height + offsetY)
//		print(offsetY, delta)
		//headerViewHeight?.constant = delta
	}

}
