//
//  JSONDownloadService.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 18.09.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit


class JSONDownloadService {
	
	public static let shared = JSONDownloadService()
	private let json = "https://drive.google.com/uc?export=download&id=1Rbk49RDjWffwbs-nMA9WaMjsaOAKWg_r"
	private var downloadTask: URLSessionDataTask?
	private let allovedUpdateInterval: TimeInterval = 3600 // not more than 1 per hour
	
	
	private init() { }
	
	
	public func downloadJSON(callback: (() -> Void)? = nil) {
		let delta = Date().timeIntervalSince1970 - UserDefaultsData.lastTimeJSONUpdated
		guard delta >= allovedUpdateInterval else { return }
		
		guard let jsonURL = URL(string: json) else { return }
		downloadTask = URLSession.shared.dataTask(with: jsonURL) {
			(data, response, error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			guard let data = data else { return }
			// let str = String(data: data, encoding: String.Encoding.utf8)
			do {
				let someData = try JSONDecoder().decode([SPurchase].self, from: data)
				self.parseJSON(availablePurchases: someData)
				callback?()
			}
			catch let err {
				print("Failed to serealize JSON", err.localizedDescription)
			}
			self.downloadTask!.cancel()
			self.downloadTask = nil
		}
		downloadTask!.resume()
	}
	
	
	private func parseJSON(availablePurchases: [SPurchase]) {
		
		
	}
	
	
}


struct SPurchase: Decodable {
	let type	:String
	let name	:String?
}
