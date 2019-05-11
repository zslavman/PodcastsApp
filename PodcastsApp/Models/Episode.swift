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
	let imageLink: String
	
	init(feedItem: RSSFeedItem, parentImageLink: String) {
		self.title 			= feedItem.title ?? ""
		self.pubDate 		= feedItem.pubDate ?? Date()
		self.description 	= feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
		imageLink = feedItem.iTunes?.iTunesImage?.attributes?.href ?? parentImageLink
	}
}
