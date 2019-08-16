//
//  EpisodeCell.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 10.05.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {

	public static let cellID = "cellID"
	@IBOutlet weak var episodeImageView: UIImageView!
	@IBOutlet weak var pubDateLabel: UILabel!
	@IBOutlet weak var sizeInMBLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.numberOfLines = 2
		}
	}
	@IBOutlet weak var descriptionLabel: UILabel! {
		didSet {
			descriptionLabel.numberOfLines = 2
		}
	}
	@IBOutlet weak var progressBar: UIProgressView!
	public var episode: Episode! {
		didSet {
			configCell()
		}
	}
	
	
	private func configCell() {
		titleLabel.text 		= episode.title
		descriptionLabel.text 	= episode.description
		pubDateLabel.text 		= SUtils.convertDate(date: episode.pubDate)
		if let url = URL(string: episode.imageLink) {
			episodeImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: [])
		}
		sizeInMBLabel.text 		= episode.fileSize
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		progressBar.isHidden = true
		episodeImageView.layer.cornerRadius = 4
		episodeImageView.layer.masksToBounds = true
		//progressBar.transform = CGAffineTransform(scaleX: 1, y: 8)
		// if want use rounded corner - set heightConstraint for progress, then use SmallProgressBar class
		
		//TODO:check if file allready downloaded - set progress hiden
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		//episode = nil
	}
	
}


class SmallProgressBar: UIProgressView {
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let maskLayerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 2)
		let maskLayer = CAShapeLayer()
		maskLayer.frame = self.bounds
		maskLayer.path = maskLayerPath.cgPath
		layer.mask = maskLayer
	}
}
