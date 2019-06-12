//
//  Podcast.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 31.03.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation

/*
*  NSCoding - for archive this class to Data
*  NSObject - fix crach on try to encode
*/
class Podcast: NSObject, Decodable, NSCoding {
	
	var trackName: String?
	var artistName: String?
	var artworkUrl600: String?
	var trackCount: Int?
	var feedUrl: String? // feeds.soundcloud.com/users/soundcloud:users:114798578/sounds.rss
	

	/*
	*  Try to transforme Podcast into Data
	*  method fill the variables from aCoder. It calls from NSKeyedArchiver.archivedData()
	*/
	func encode(with aCoder: NSCoder) {
		aCoder.encode(trackName ?? "", forKey: "trackNameKey")
		aCoder.encode(artistName ?? "", forKey: "artistNameKey")
		aCoder.encode(artworkUrl600 ?? "", forKey: "artworkUrl600Key")
	}
	
	// Try to return Data into Podcast
	required init?(coder aDecoder: NSCoder) {
		trackName = aDecoder.decodeObject(forKey: "trackNameKey") as? String
		artistName = aDecoder.decodeObject(forKey: "artistNameKey") as? String
		artworkUrl600 = aDecoder.decodeObject(forKey: "artworkUrl600Key") as? String
	}

}
