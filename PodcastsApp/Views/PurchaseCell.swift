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
		label.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
		return label
	}()
	private let descriptionText: UITextView = {
		let textView = UITextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.font = UIFont.systemFont(ofSize: 13, weight: .regular)
		textView.isEditable = false
		textView.isSelectable = false
		textView.isScrollEnabled = true
		textView.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
		textView.text = "Исследование жизненного пути личности, осознания прошлых событий в жизни человека, а также планирования будущего."
		return textView
	}()
	private let priceLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
		label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		label.textAlignment = .center
		label.adjustsFontSizeToFitWidth = true
		return label
	}()
	private let button: UIButton = {
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
		return bttn
	}()
	private let sizeLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 8, weight: .bold)
		label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
		label.textAlignment = .center
		label.numberOfLines = 0
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
	private var viewModel: SKProduct!
	
	
	static func identifier() -> String {
		return "\(self.classForCoder())"
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		setupLayout()
		selectionStyle = .none
		button.addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
		NotificationCenter.default.addObserver(self, selector: #selector(updateProgress(notif:)),
											   name: .purchaseDownloadsUpdated, object: nil)
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
		let vertStack2 = UIStackView(arrangedSubviews: [mainTitle, descriptionText])
		vertStack2.axis = .vertical
		vertStack2.spacing = 3

		let vertStack3 = UIStackView(arrangedSubviews: [priceLabel, button, sizeLabel])
		vertStack3.axis = .vertical
		vertStack3.spacing = 3
		vertStack3.isLayoutMarginsRelativeArrangement = true
		vertStack3.layoutMargins = .init(top: 10, left: 5, bottom: 10, right: 5)
		vertStack3.distribution = .fillProportionally
		
		let backViewForStack3 = UIView()
		backViewForStack3.backgroundColor = #colorLiteral(red: 0.9402040993, green: 0.9402040993, blue: 0.9402040993, alpha: 1)
		//backViewForStack3.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		backViewForStack3.layer.cornerRadius = 8
		backViewForStack3.clipsToBounds = true
		backViewForStack3.layer.borderWidth = 0.5
		backViewForStack3.layer.borderColor = #colorLiteral(red: 0.8844061932, green: 0.8844061932, blue: 0.8844061932, alpha: 1).cgColor
		backViewForStack3.addSubview(vertStack3)
		vertStack3.fillSuperView()
		
		let mainHorStack = UIStackView(arrangedSubviews: [purchaseImage, vertStack2, backViewForStack3])
		mainHorStack.axis = .horizontal
		mainHorStack.spacing = 5
		mainHorStack.distribution = .fill
		mainHorStack.isLayoutMarginsRelativeArrangement = true
		mainHorStack.layoutMargins = .init(top: 5, left: 10, bottom: 5, right: 10)
		
		let fakeView = UIView() // invisible view which help set a footer empty space
		
		let mainVertStack = UIStackView(arrangedSubviews: [mainHorStack, fakeView])
		mainVertStack.axis = .vertical
		addSubview(mainVertStack)
		mainVertStack.fillSuperView()
		
		addSubview(progressBar)
		
		NSLayoutConstraint.activate([
			purchaseImage.widthAnchor.constraint(equalToConstant: 120),
			purchaseImage.heightAnchor.constraint(equalToConstant: 110),
			button.heightAnchor.constraint(equalToConstant: 40),
			fakeView.heightAnchor.constraint(equalToConstant: 5),
			backViewForStack3.widthAnchor.constraint(equalToConstant: 85),
			progressBar.widthAnchor.constraint(equalToConstant: PurchaseCell.PROGRESS_SIZE),
			progressBar.heightAnchor.constraint(equalToConstant: PurchaseCell.PROGRESS_SIZE),
			progressBar.centerXAnchor.constraint(equalTo: purchaseImage.centerXAnchor),
			progressBar.centerYAnchor.constraint(equalTo: purchaseImage.centerYAnchor),
		])
	}
	
	
	//MARK: configure cell
	public func configureWith(productViewModel: SKProduct, jsonModel: PurchModel?) {
		guard let safeJSONModel = jsonModel else {
			fatalError("Error: Can't get necessary PurchModel from parsed JSON!")
		}
		let imageURL = URL(string: safeJSONModel.imageURL)!
		purchaseImage.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: [], context: nil)
		viewModel = productViewModel
		priceLabel.text = viewModel.localizedPrice
		mainTitle.text = safeJSONModel.title.ru
		descriptionText.text = safeJSONModel.descript_short.ru
		setFileSize()
		let prog = IAPManager.shared.getProgressForIdentifier(id: viewModel.productIdentifier) // return -1 if not found
		if prog >= 0 {
			progressBar.progress = prog
			button.isEnabled = false
			setFileSizeWithProgress(curProgress: prog)
			return
		}
		progressBar.isHidden = true
		
		if IAPManager.shared.suspendedPurchaseIDs.contains(viewModel.productIdentifier) {
			button.isEnabled = false
		}
		else {
			button.isEnabled = true
		}
		
		//TODO: check id in already purchased dataBase
		let purchased = false
		let purchasedVer = 1.0
		guard purchased else { return }
		
		let newestVer = Double(viewModel.downloadContentVersion) ?? 0
		if purchasedVer < newestVer {
			button.setTitle("Обновить", for: .normal)
			priceLabel.text = "Бесплатно"
		}
		else {
			button.setTitle("Куплено", for: .normal)
			button.isEnabled = false
		}
	}
	
	
	@objc private func updateProgress(notif: Notification) {
		guard let updateObj = notif.object as? [SKDownload] else { return }
		guard let desiredDownload = (updateObj.filter{ $0.contentIdentifier == viewModel.productIdentifier }).first
		else { return }
		let progress = Double(desiredDownload.progress)
		DispatchQueue.main.async {
			self.progressBar.progress = progress
			self.setFileSizeWithProgress(curProgress: progress)
		}
	}
	
	
	private func setFileSize() {
		guard let wholeSizeNumber = viewModel.downloadContentLengths.first else { return }
		let fileSizeInt = wholeSizeNumber.int64Value
		let formatter = ByteCountFormatter()
		formatter.countStyle = .file
		formatter.includesUnit = false
		let formatedSize = formatter.string(fromByteCount: fileSizeInt)
		sizeLabel.text = "Размер: \(formatedSize) МБ"
	}
	
	
	private func setFileSizeWithProgress(curProgress: Double) {
		guard let wholeFileSizeNumber = viewModel.downloadContentLengths.first else { return }
		let wholeFileSizeInt = wholeFileSizeNumber.int64Value
		let formatter = ByteCountFormatter()
		formatter.countStyle = .file
		let downloadedSize = Double(wholeFileSizeInt) * curProgress
		let downloadedFormatedSize = formatter.string(fromByteCount: Int64(downloadedSize))
		let wholeFormatedSize = formatter.string(fromByteCount: wholeFileSizeInt)
		sizeLabel.text = "\(downloadedFormatedSize) / \(wholeFormatedSize)"
	}
	
	
	@objc private func onButtonClick() {
		print("Did click Purchase!")
		button.isEnabled = false
		IAPManager.shared.purchaseProduct(productID: viewModel.productIdentifier)
		delegate?.showHUD()
	}
	
	
}
