//
//  FavoritePodcastCellCollectionViewCell.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 11.06.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

class FavoritePodcastCell: UICollectionViewCell {
	
	public static let favCellIdentifier = "favCellIdentifier"
	private let imageView = UIImageView(image: #imageLiteral(resourceName: "appicon"))
	private let nameLabel: UILabel = {
		let label = UILabel()
		label.text = "Podcast Name"
		label.font = UIFont.boldSystemFont(ofSize: 15)
		return label
	}()
	private let artistNameLabel: UILabel = {
		let label = UILabel()
		label.text = "Artist Name"
		label.font = UIFont.systemFont(ofSize: 14)
		label.textColor = .lightGray
		return label
	}()
	
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	private func setup() {
		let stackView = UIStackView(arrangedSubviews: [
			imageView,
			nameLabel,
			artistNameLabel
		])
		stackView.axis = .vertical
		stackView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stackView)
		
		NSLayoutConstraint.activate([
			imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),// picture must be square
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
		])
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
}
