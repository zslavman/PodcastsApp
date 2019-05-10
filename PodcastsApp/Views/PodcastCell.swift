//
//  PodcastCell.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 17.04.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
	
	public static let cellID = "cellID"
	@IBOutlet weak var podcastImageView: UIImageView!
	@IBOutlet weak var trackName: UILabel!
	@IBOutlet weak var artistName: UILabel!
	@IBOutlet weak var episodeName: UILabel!
	
	public var podcast: Podcast! {
		didSet {
			trackName.text = podcast.trackName
			artistName.text = podcast.artistName
			
			episodeName.text = "\(podcast.trackCount ?? 0) Эпизод."
			
			guard let url = URL(string: podcast.artworkUrl600 ?? "") else { return }
			podcastImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "image_placeholder"), options: [], context: nil)
		}
	}
	
}
