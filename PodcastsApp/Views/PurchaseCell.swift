//
//  PurchaseCell.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 15.09.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseCell: UITableViewCell {
	
	private let purchaseImage: UIImageView = {
		let img = UIImageView(image: #imageLiteral(resourceName: "sample"))
		img.translatesAutoresizingMaskIntoConstraints = false
		img.contentMode = .scaleAspectFill
		img.layer.cornerRadius = 8
		img.clipsToBounds = true
		return img
	}()
	private let mainTitle: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
		label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
		label.textAlignment = .center
		label.text = "Линия жизни"
		label.numberOfLines = 0
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
		label.text = "1.99 $"
		label.numberOfLines = 0
		label.sizeToFit()
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
		return bttn
	}()
	private let sizeLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
		label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
		label.textAlignment = .center
		label.text = "Размер: 8 Мб"
		label.numberOfLines = 0
		return label
	}()
	private let progress: UILabel!
	private var viewModel: SKProduct!
	
	
	static func identifier() -> String {
		return "\(self.classForCoder())"
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		setupLayout()
		selectionStyle = .none
		button.addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	private func setupLayout() {
		let vertStack2 = UIStackView(arrangedSubviews: [mainTitle, descriptionText])
		vertStack2.axis = .vertical
		vertStack2.spacing = 3

		let vertStack3 = UIStackView(arrangedSubviews: [priceLabel, button, sizeLabel])
		vertStack3.axis = .vertical
		vertStack3.spacing = 3
		vertStack3.isLayoutMarginsRelativeArrangement = true
		vertStack3.layoutMargins = .init(top: 10, left: 0, bottom: 0, right: 0)
		vertStack3.distribution = .fillProportionally
		
		let mainHorStack = UIStackView(arrangedSubviews: [purchaseImage, vertStack2, vertStack3])
		mainHorStack.axis = .horizontal
		mainHorStack.spacing = 5
		mainHorStack.distribution = .fill
		mainHorStack.isLayoutMarginsRelativeArrangement = true
		mainHorStack.layoutMargins = .init(top: 5, left: 10, bottom: 5, right: 10)
		
		let fakeView = UIView()
		
		let mainVertStack = UIStackView(arrangedSubviews: [mainHorStack, fakeView])
		mainVertStack.axis = .vertical
		addSubview(mainVertStack)
		mainVertStack.fillSuperView()
		
		NSLayoutConstraint.activate([
			purchaseImage.widthAnchor.constraint(equalToConstant: 120),
			purchaseImage.heightAnchor.constraint(equalToConstant: 110),
			button.heightAnchor.constraint(equalToConstant: 40),
			fakeView.heightAnchor.constraint(equalToConstant: 5),
			vertStack3.widthAnchor.constraint(equalToConstant: 80),
		])
	}
	
	
	public func configureWith(productViewModel: SKProduct) {
		viewModel = productViewModel
		priceLabel.text = viewModel.localizedPrice
		mainTitle.text = viewModel.localizedTitle
		descriptionText.text = viewModel.localizedDescription
	}
	
	@objc private func onButtonClick() {
		print("Did click Purchase!")
		button.isEnabled = false
		IAPManager.shared.purchaseProduct(productID: viewModel.productIdentifier)
	}
	
	
}
