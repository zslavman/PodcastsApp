//
//  PlayerDetailsView.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 11.05.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

class PlayerDetailsView: UIView {
	
	@IBOutlet weak var titleImage: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	public var episode: Episode! {
		didSet {
			titleLabel.text = episode.title
			guard let url = URL(string: episode.imageLink) else { return }
			titleImage.sd_setImage(with: url)
		}
	}
	
	@IBAction func onDismissClick(_ sender: Any) {
		self.removeFromSuperview()	
	}
	
	
	
}
