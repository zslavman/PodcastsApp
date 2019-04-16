//
//  AlamofireService.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 17.04.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation
import Alamofire


class AlamofireService {
	
	public static let shared = AlamofireService()
	
	
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
	
	
	
}
