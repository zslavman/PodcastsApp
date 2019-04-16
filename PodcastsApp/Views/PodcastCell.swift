//
//  PodcastCell.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 17.04.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

class PodcastCell: UITableViewCell {
	
	@IBOutlet weak var podcastImageView: UIImageView!
	@IBOutlet weak var trackName: UILabel!
	@IBOutlet weak var artistName: UILabel!
	@IBOutlet weak var episodeName: UILabel!
	
	public var podcast: Podcast! {
		didSet {
			trackName.text = podcast.trackName
			artistName.text = podcast.artistName
		}
	}
	
}
