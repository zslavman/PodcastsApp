//
//  Podcast.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 31.03.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation

struct Podcast: Decodable {
	var trackName: String?
	var artistName: String?
	var artworkUrl600: String?
	var trackCount: Int?
	var feedUrl: String? // feeds.soundcloud.com/users/soundcloud:users:114798578/sounds.rss
}
