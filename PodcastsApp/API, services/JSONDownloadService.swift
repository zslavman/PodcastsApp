//
//  JSONDownloadService.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 18.09.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit


struct JSONDownloadService {
	
	public static let shared = JSONDownloadService()
	private let json = "https://drive.google.com/uc?export=download&id=1Rbk49RDjWffwbs-nMA9WaMjsaOAKWg_r"
	private var downloadTask = URLSessionDataTask()
	
	
	private init() { }
	
	
	
	public func downloadCompaniesFromServer(callback: (() -> Void)?) {
		guard let jsonURL = URL(string: json) else { return }
		let task = URLSession.shared.dataTask(with: jsonURL) {
			(data, response, error) in
			if let error = error {
				print(error.localizedDescription)
				return
			}
			guard let data = data else { return }
			// let str = String(data: data, encoding: String.Encoding.utf8)
			do {
				let someData = try JSONDecoder().decode([SPurchase].self, from: data)
				self.parseJSON(someData: someData)
				callback?()
			}
			catch let err {
				print("Failed to serealize JSON", err.localizedDescription)
			}
		}
	}
	
	
	private func parseJSON() {
		
	}
	
	
	
}


struct SPurchase: Decodable {
	let name		:String?
	let type		:String?
}
