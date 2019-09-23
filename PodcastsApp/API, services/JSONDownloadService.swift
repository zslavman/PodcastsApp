//
//  JSONDownloadService.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 18.09.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit


class JSONDownloadService: NSObject {
	
	public static let shared = JSONDownloadService()
	//private let json = "https://drive.google.com/uc?export=download&id=1LZrlmX3mrl8lSYq-gYa9v5xrVfYRG3GU"
	private let json = "https://drive.google.com/uc?export=view&id=1LZrlmX3mrl8lSYq-gYa9v5xrVfYRG3GU"
	private var downloadTask: URLSessionDataTask?
	private let allovedUpdateInterval: TimeInterval = 1800 // not more than 1 per hour
	public var parsed = [PurchModel]()
	private let session = URLSession(configuration: .default)
	
	
	private init(test: String = "") { }
	
	
	public func downloadNewJSON() {
		let delta = Date().timeIntervalSince1970 - UserDefaultsData.lastTimeJSONUpdated
		guard parsed.isEmpty || delta >= allovedUpdateInterval else {
			return
		}
		if downloadTask != nil { return }
		guard let jsonURL = URL(string: json) else { return }
		downloadTask = session.dataTask(with: jsonURL) {
			(data, response, error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			guard let data = data else { return }
			// let str = String(data: data, encoding: String.Encoding.utf8)
			do {
				let someData = try JSONDecoder().decode([PurchModel].self, from: data)
				//self.parseJSON(availablePurchases: someData)
				self.parsed = someData
				UserDefaultsData.lastTimeJSONUpdated = Date().timeIntervalSince1970
				NotificationCenter.default.post(name: .gotNewJSON, object: nil)
				print("Successfully download new JSON!")
			}
			catch let err {
				print("Failed to serealize JSON", err.localizedDescription)
			}
			self.downloadTask?.cancel()
			self.downloadTask = nil
		}
		downloadTask!.resume()
		print("Started URLSession with: \(jsonURL)")
	}
	
}


extension JSONDownloadService: URLSessionTaskDelegate {
	
	func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		if let err = error {
			print("Error 50000:", err.localizedDescription)
		}
	}
	
}


struct PurchModel: Decodable {
	let title			: DictionaryCell
	let descript_short	: DictionaryCell
	let descript_long	: DictionaryCell
	let purchaseID		: String
	let type			: String
	let order			: UInt
	let imageURL		: String
	let reserved1		: String
	let reserved2		: String
}

struct DictionaryCell: Decodable {
	let ru : String
	let ua : String
}
