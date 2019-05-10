//
//  Episode.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 10.05.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation
import FeedKit

struct Episode {
	
	let title: String
	let pubDate: Date
	let description: String
	
	init(feedItem: RSSFeedItem) {
		self.title 			= feedItem.title ?? ""
		self.pubDate 		= feedItem.pubDate ?? Date()
		self.description 	= feedItem.description ?? ""
	}
}
