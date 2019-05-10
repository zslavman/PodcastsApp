//
//  RSSFeed.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 11.05.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import FeedKit

extension RSSFeed {
	
	func toEpisodes() -> [Episode] {
		let parentImageLink = iTunes?.iTunesImage?.attributes?.href ?? ""
		var episodes = [Episode]()
		items?.forEach({
			(feedItem) in
			let episode = Episode(feedItem: feedItem, parentImageLink: parentImageLink)
			episodes.append(episode)
		})
		return episodes
	}
}
