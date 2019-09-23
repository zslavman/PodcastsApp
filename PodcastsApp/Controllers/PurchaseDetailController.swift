//
//  PurchaseDetailController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 24.09.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit


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
		label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
		label.textAlignment = .left
		label.numberOfLines = 0
		return label
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
		
	}
	
	
	public func initWith(productID: String) {
		self.productID = productID
		guard let purchData = ((JSONDownloadService.shared.parsed).filter{ $0.purchaseID == productID }).first
		else { return }
		
		let scrollView = UIScrollView()
		scrollView.alwaysBounceVertical = true
		view.addSubview(scrollView)
		scrollView.fillSuperView()
		
		guard let url = URL(string: purchData.imageURL) else { return }
		
		productImg.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: [])
		descriptionText.text = purchData.descript_long.ru
		
		scrollView.addSubview(productImg)
		scrollView.addSubview(descriptionText)
		
		NSLayoutConstraint.activate([
			productImg.topAnchor.constraint(equalTo: scrollView.topAnchor),
			productImg.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			productImg.widthAnchor.constraint(equalTo: view.widthAnchor),
			productImg.heightAnchor.constraint(equalTo: view.widthAnchor),
			descriptionText.topAnchor.constraint(equalTo: productImg.bottomAnchor, constant: 20),
			descriptionText.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
			descriptionText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
		])
	}
	
	
}
