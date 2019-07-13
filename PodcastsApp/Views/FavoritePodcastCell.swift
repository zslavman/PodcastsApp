//
//  FavoritePodcastCell.swift
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
	private let checkBox: UIView = {
		let box = UIView()
		box.backgroundColor = UIColor.white.withAlphaComponent(0.9)
		box.layer.cornerRadius = 8
		box.layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1).cgColor
		box.layer.borderWidth = 1
		box.translatesAutoresizingMaskIntoConstraints = false
		//box.isHidden = true
		return box
	}()
	private let checkMark: UIImageView = {
		let checkmark = UIImageView(image: #imageLiteral(resourceName: "check-mark"))
		checkmark.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
		checkmark.translatesAutoresizingMaskIntoConstraints = false
		checkmark.contentMode = .scaleAspectFit
		return checkmark
	}()
	public var podcast: Podcast!
	
	override var isSelected: Bool {
		didSet {
			if isSelected {
				imageView.alpha = 0.3
			}
			else {
				imageView.alpha = 1
			}
		}
	}
	
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
		addSubview(checkBox)
		addSubview(checkMark)
		
		NSLayoutConstraint.activate([
			imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),// picture must be square
			stackView.topAnchor.constraint(equalTo: topAnchor),
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
			
			checkBox.topAnchor.constraint(equalTo: topAnchor, constant: 7),
			checkBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7),
			checkBox.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.35),
			checkBox.heightAnchor.constraint(equalTo: checkBox.widthAnchor),
			
			checkMark.centerXAnchor.constraint(equalTo: checkBox.centerXAnchor),
			checkMark.centerYAnchor.constraint(equalTo: checkBox.centerYAnchor),
			checkMark.widthAnchor.constraint(equalTo: checkBox.widthAnchor, multiplier: 0.9),
			checkMark.heightAnchor.constraint(equalTo: checkMark.widthAnchor),
		])
	}
	
	public func configure(passedPodcast: Podcast) {
		podcast = passedPodcast
		nameLabel.text = podcast.trackName
		artistNameLabel.text = podcast.artistName
		if let url = URL(string: podcast.artworkUrl600!) {
			imageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: [])
			imageView.layer.cornerRadius = 8
			imageView.layer.masksToBounds = true
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		imageView.layer.cornerRadius = 8
		imageView.layer.masksToBounds = true
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func prepareForReuse() {
		super.prepareForReuse()
		isSelected = false
	}
	
	
}
