//
//  Podcast.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 31.03.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation
import AXPhotoViewer


struct SearchResult: Decodable {
	let resultCount: Int
	let results: [Podcast]
}

/*
*  NSCoding - for archive this class to Data
*  NSObject - fix crach on try to encode
*/
class Podcast: NSObject, Decodable, NSCoding, AXPhotoProtocol  {
	
	// AXPhotoProtocol stubs
	var imageData: Data?
	//var image: UIImage? // UIImage type does not conform to protocol 'Decodable'
	var dataForImage: Data?
	var url: URL?
	
	// Equatable doesn't work with NSObject
//	public static func == (lhs: Podcast, rhs: Podcast) -> Bool {
//		return lhs.trackName == rhs.trackName &&
//		lhs.artistName == rhs.artistName
//	}
	
	override func isEqual(_ object: Any?) -> Bool {
		if let equatablePodcast = object as? Podcast {
			if equatablePodcast.artistName == artistName &&
				equatablePodcast.trackName == trackName { //&&
				//equatablePodcast.feedUrl == feedUrl {
				return true
			}
		}
		return false
	}
	
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
		aCoder.encode(feedUrl ?? "", forKey: "feedUrlKey")
		aCoder.encode(trackCount ?? "", forKey: "trackCountKey")
	}
	
	// Try to return Data into Podcast
	required init?(coder aDecoder: NSCoder) {
		trackName = aDecoder.decodeObject(forKey: "trackNameKey") as? String
		artistName = aDecoder.decodeObject(forKey: "artistNameKey") as? String
		artworkUrl600 = aDecoder.decodeObject(forKey: "artworkUrl600Key") as? String
		feedUrl = aDecoder.decodeObject(forKey: "feedUrlKey") as? String
		trackCount = aDecoder.decodeObject(forKey: "trackCountKey") as? Int
		
		if let safeURL = artworkUrl600 {
			url = URL(string: safeURL)
		}
	}

}


// ugly trick to confirm AXPhotoProtocol
extension Podcast {

	var image: UIImage? {
		get {
			if let dd = dataForImage {
				return UIImage(data: dd)
			}
			return nil
		}
		set {
			dataForImage = newValue?.jpegData(compressionQuality: 1.0)
		}
	}
}
