//
//  AlamofireService.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 17.04.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class APIServices {
	
	public static let shared = APIServices()
	
	
	public func fetchPodcasts(searchText: String, callback: @escaping ([Podcast]) -> Void) {
		let url = "https://itunes.apple.com/search"
		let params = [
			"term": searchText,
			"media": "podcast" // media filter (see API)
		]
		Alamofire.request(url,
						  method: .get,
						  parameters: params,
						  encoding: URLEncoding.default, // turn spaces into "%20"
			headers: nil)
			.responseData {
				(dataResponse) in
				if let error = dataResponse.error {
					print("Error: \(error.localizedDescription)")
					return
				}
				guard let data = dataResponse.data else { return }
				do {
					let decoded = try JSONDecoder().decode(SearchResult.self, from: data)
					callback(decoded.results)
				}
				catch let err {
					print("Failed to parse", err.localizedDescription)
				}
		}
	}
	
	
	public func fetchEpisodes(urlString: String, completionHandler: @escaping ([Episode]) ->()) {
		let secureFeedString = urlString//.toSecureHTTPS()
		guard let feedUrl = URL(string: secureFeedString) else { return }
		
		// fix small delay on clicking a cell
		DispatchQueue.global(qos: .background).async {
			let parser = FeedParser(URL: feedUrl)
			
			parser.parseAsync {
				(result) in
				var episodes = [Episode]()
				// How to access a Swift enum associated value outside of a switch statement:
				// variant 1
				//if case .rss(let value) = result { }
				
				// variant 2
				// associative enum value
				switch result {
				case .failure(let error):
					print("Error retrieving data:", error.localizedDescription)
				case .rss(let feed):		// Really Simple Syndication Feed Model
					episodes = feed.toEpisodes()
					completionHandler(episodes)
				default:
					print("Found a feed, use another enum value!")
				}
			}
		}
		
		
	}
	
	
}
