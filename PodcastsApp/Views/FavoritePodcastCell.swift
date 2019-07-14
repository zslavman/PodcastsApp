//
//  FavoritePodcastCell.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 11.06.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

protocol FavoritesControllerDelegate:class {
	func currentEditStatus() -> Bool
}

class FavoritePodcastCell: UICollectionViewCell {
	
	weak var delegate: FavoritesControllerDelegate?
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
		box.alpha = 0
		return box
	}()
	private let checkMark: UIImageView = {
		let checkmark = UIImageView(image: #imageLiteral(resourceName: "check-mark"))
		checkmark.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
		checkmark.translatesAutoresizingMaskIntoConstraints = false
		checkmark.contentMode = .scaleAspectFit
		checkmark.isHidden = true
		return checkmark
	}()
	public var podcast: Podcast!
	
	override var isSelected: Bool {
		didSet {
			if let delegate = delegate {
				if !delegate.currentEditStatus() { return } // don't select on click
			}
			if isSelected {
				imageView.alpha = 0.3
				checkMark.isHidden = false
			}
			else {
				imageView.alpha = 1
				checkMark.isHidden = true
			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
		NotificationCenter.default.addObserver(self, selector: #selector(configCheckBox(notification:)),
											   name: .editModeChahged, object: nil)
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
			checkMark.widthAnchor.constraint(equalTo: checkBox.widthAnchor, multiplier: 0.6),
			checkMark.heightAnchor.constraint(equalTo: checkMark.widthAnchor),
		])
	}
	
	
	public func configure(passedPodcast: Podcast, hasSelection: Bool) {
		if let delegate = delegate {
			setCheckBox(delegate.currentEditStatus())
			isSelected = hasSelection
		}
		podcast = passedPodcast
		nameLabel.text = podcast.trackName
		artistNameLabel.text = podcast.artistName
		if let url = URL(string: podcast.artworkUrl600!) {
			imageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: [])
			imageView.layer.cornerRadius = 8
			imageView.layer.masksToBounds = true
		}
	}
	
	
	@objc private func configCheckBox(notification: Notification) {
		guard let isEditMode = notification.object as? Bool else { return }
		setCheckBox(isEditMode, animate: true)
	}
	
	
	private func setCheckBox(_ isEditMode: Bool, animate: Bool = false) {
		if isEditMode {
			let duration = animate ? 0.3 : 0
			UIView.animate(withDuration: duration) {
				self.checkBox.transform = .identity
				self.checkBox.alpha = 1
			}
		}
		else {
			UIView.animate(withDuration: 0.3) {
				let scaleTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)// dont set to 0 - this will ignore duration
				self.checkBox.transform = scaleTransform
				self.checkBox.alpha = 0
			}
			checkMark.isHidden = true
			imageView.alpha = 1
		}
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	
	override func prepareForReuse() {
		super.prepareForReuse()
		checkMark.isHidden = true
		checkBox.alpha = 0
		imageView.alpha = 1
	}
	
	
}
