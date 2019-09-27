//
//  PurchaseCell.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 15.09.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit
import StoreKit
import PKHUD
import MaterialComponents.MaterialActivityIndicator


protocol PurchaseCellDelegate: class {
	func showHUD()
}

class PurchaseCell: UITableViewCell {
	
	weak var delegate: PurchaseCellDelegate!
	static let PROGRESS_SIZE: CGFloat = 80
	private let purchaseImage: UIImageView = {
		let img = UIImageView(image: #imageLiteral(resourceName: "sample"))
		img.translatesAutoresizingMaskIntoConstraints = false
		img.contentMode = .scaleAspectFill
		img.layer.cornerRadius = 8
		img.clipsToBounds = true
		return img
	}()
	private let mainTitle: UILabelWithEdges = {
		let label = UILabelWithEdges()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		label.textAlignment = .left
		label.numberOfLines = 0
		label.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
//		label.adjustsFontSizeToFitWidth = true
//		label.lineBreakMode = .byWordWrapping
		return label
	}()
	private let descriptionText: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
		label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
		label.numberOfLines = 0
		return label
	}()
	private let buyButton: UIButton = {
		let bttn = UIButton(type: .system)
		bttn.translatesAutoresizingMaskIntoConstraints = false
		bttn.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
		bttn.setTitle("Купить", for: .normal)
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
	private let arrowLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
		label.textAlignment = .center
		//label.numberOfLines = 0
		label.text = "〉" // 〉〉
		return label
	}()
	private var progressBar: CircleProgressBar = {
		let proBar = CircleProgressBar(frame: .zero)
		proBar.translatesAutoresizingMaskIntoConstraints = false
		proBar.trackWidth = 3
		proBar.trackBorderWidth = 3
		proBar.trackFillColor = .white
		proBar.roundedCap = true
		proBar.trackBackgroundColor = .clear
		proBar.centerFillColor = .clear
		proBar.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		proBar.layer.cornerRadius = PROGRESS_SIZE / 2
		proBar.layer.masksToBounds = true
		proBar.isHidden = true
		return proBar
	}()
	private let arrowButton: UIButton = {
		let arrowBut = UIButton()
		arrowBut.backgroundColor = #colorLiteral(red: 0.9402040993, green: 0.9402040993, blue: 0.9402040993, alpha: 1)
		arrowBut.layer.cornerRadius = 5
		arrowBut.clipsToBounds = true
		arrowBut.layer.borderWidth = 0.5
		arrowBut.layer.borderColor = #colorLiteral(red: 0.8844061932, green: 0.8844061932, blue: 0.8844061932, alpha: 1).cgColor
		return arrowBut
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
	private var viewModel: SKProduct!
	
	
	static func identifier() -> String {
		return "\(self.classForCoder())"
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		setupLayout()
		selectionStyle = .none
		buyButton.addTarget(self, action: #selector(onBuyClick), for: .touchUpInside)
		NotificationCenter.default.addObserver(self, selector: #selector(updateProgress(notif:)),
											   name: .purchaseDownloadsUpdated, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(purchaseDidChangeStatus(notif:)),
											   name: .purchaseDownloadingCompleted, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(purchaseDidChangeStatus(notif:)),
											   name: .purchaseDownloadingError, object: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		purchaseImage.image = nil
	}
	
	
	private func setupLayout() {
		let horStackTitleButton = UIStackView(arrangedSubviews: [mainTitle, buyButton])
		horStackTitleButton.axis = .horizontal
		horStackTitleButton.spacing = 3
		
		let vertStack2 = UIStackView(arrangedSubviews: [horStackTitleButton, descriptionText])
		vertStack2.axis = .vertical
		vertStack2.spacing = 3
		vertStack2.isLayoutMarginsRelativeArrangement = true
		vertStack2.layoutMargins = .init(top: 0, left: 5, bottom: 0, right: 5)

		arrowButton.addSubview(arrowLabel)
		
		let mainHorStack = UIStackView(arrangedSubviews: [purchaseImage, vertStack2, arrowButton])
		mainHorStack.axis = .horizontal
		mainHorStack.spacing = 5
		mainHorStack.distribution = .fill
		mainHorStack.isLayoutMarginsRelativeArrangement = true
		mainHorStack.layoutMargins = .init(top: 5, left: 10, bottom: 5, right: 10)
		
		let emptyTopView = UIView() // invisible view which help set a footer empty space
		let emptyBotView = UIView()
		
		let mainVertStack = UIStackView(arrangedSubviews: [emptyTopView, mainHorStack, emptyBotView])
		mainVertStack.axis = .vertical
		addSubview(mainVertStack)
		mainVertStack.fillSuperView()
		
		addSubview(progressBar)
		
		buyButton.addSubview(activityIndicator)
		
		NSLayoutConstraint.activate([
			purchaseImage.widthAnchor.constraint(equalToConstant: 110),
			purchaseImage.heightAnchor.constraint(equalToConstant: 110),
			buyButton.heightAnchor.constraint(equalToConstant: 30),
			buyButton.widthAnchor.constraint(equalToConstant: 60),
			emptyTopView.heightAnchor.constraint(equalToConstant: 5),
			emptyBotView.heightAnchor.constraint(equalToConstant: 5),
			arrowButton.widthAnchor.constraint(equalToConstant: 15),
			progressBar.widthAnchor.constraint(equalToConstant: PurchaseCell.PROGRESS_SIZE),
			progressBar.heightAnchor.constraint(equalToConstant: PurchaseCell.PROGRESS_SIZE),
			progressBar.centerXAnchor.constraint(equalTo: purchaseImage.centerXAnchor),
			progressBar.centerYAnchor.constraint(equalTo: purchaseImage.centerYAnchor),
			arrowLabel.centerXAnchor.constraint(equalTo: arrowButton.centerXAnchor, constant: 5),
			arrowLabel.centerYAnchor.constraint(equalTo: arrowButton.centerYAnchor),
			arrowLabel.widthAnchor.constraint(equalToConstant: 15),
			activityIndicator.centerXAnchor.constraint(equalTo: buyButton.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: buyButton.centerYAnchor),
		])
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
	
	
	//MARK: configure cell
	public func configureWith(productViewModel: SKProduct, jsonModel: PurchModel?) {
		guard let safeJSONModel = jsonModel else {
			fatalError("Error: Can't get necessary PurchModel from parsed JSON!")
		}
		let imageURL = URL(string: safeJSONModel.imageURL)!
		purchaseImage.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: [], context: nil)
		viewModel = productViewModel
		buyButton.setTitle(viewModel.localizedPrice, for: .normal)
		mainTitle.text = safeJSONModel.title.ru
		descriptionText.text = safeJSONModel.descript_short.ru
		let prog = IAPManager.shared.getProgressForIdentifier(id: viewModel.productIdentifier) // return -1 if not found
		if prog >= 0 {
			progressBar.progress = prog
			buyButton.isEnabled = false
			//setFileSizeWithProgress(curProgress: prog)
			return
		}
		progressBar.isHidden = true
		
		if IAPManager.shared.suspendedPurchaseIDs.contains(viewModel.productIdentifier) {
			setActivityIndicator(isActive: true)
		}
		else {
			setActivityIndicator(isActive: false)
		}
		//TODO: check id in already purchased dataBase
		let purchased = false
		let purchasedVer = 1.0
		guard purchased else { return }
		
		let newestVer = Double(viewModel.downloadContentVersion) ?? 0
		if purchasedVer < newestVer {
			buyButton.setTitle("Обновить", for: .normal)
		}
		else {
			buyButton.setTitle("Куплено", for: .normal)
			buyButton.isEnabled = false
		}
	}
	
	
	@objc private func updateProgress(notif: Notification) {
		guard let updateObj = notif.object as? [SKDownload] else { return }
		guard let desiredDownload = (updateObj.filter{ $0.contentIdentifier == viewModel.productIdentifier }).first
		else { return }
		let progress = Double(desiredDownload.progress)
		DispatchQueue.main.async {
			self.progressBar.progress = progress
		}
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
		guard let safeID = purchID, safeID == viewModel.productIdentifier else { return }
		setActivityIndicator(isActive: false)
	}
	
	
	@objc private func onBuyClick() {
		IAPManager.shared.purchaseProduct(productID: viewModel.productIdentifier)
		//delegate?.showHUD()
		setActivityIndicator(isActive: true)
	}
	
}
