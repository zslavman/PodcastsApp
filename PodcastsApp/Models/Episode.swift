//
//  Episode.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 10.05.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//  Давай 

import Foundation
import FeedKit

// Codable = Decodable + Encodable,  Encodable - for JSONEncoder().encode
struct Episode: Codable {
	
	let title: String
	let pubDate: Date
	let description: String
	let imageLink: String
	let author: String
	let strimLink: String
	
	
	init(feedItem: RSSFeedItem, parentImageLink: String) {
		strimLink 			= feedItem.enclosure?.attributes?.url ?? "" // audio-file link
		self.title 			= feedItem.title ?? ""
		self.author 		= feedItem.iTunes?.iTunesAuthor ?? ""
		self.pubDate 		= feedItem.pubDate ?? Date()
		self.description 	= feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
		imageLink 			= feedItem.iTunes?.iTunesImage?.attributes?.href ?? parentImageLink
	}
}
