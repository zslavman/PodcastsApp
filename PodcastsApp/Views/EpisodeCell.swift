//
//  EpisodeCell.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 10.05.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {

	@IBOutlet weak var episodeImageView: UIImageView!
	@IBOutlet weak var pubDateLabel: UILabel!
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
			episodeImageView.sd_setImage(with: url, completed: nil)
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
}
