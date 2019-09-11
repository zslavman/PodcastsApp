//
//  IAPManager.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 11.08.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation

// this enum need to be received from third party server!
enum IAPProducts: String, CaseIterable {
	case purchase1 = "com.zslavman.Purchase1"
	case purchase2 = "com.zslavman.Purchase2"
	case purchase3 = "com.zslavman.Purchase3"
	
	// call "IAPProducts.allCases" to get an array of all cases
}

class IAPManager {
	
	public static let shared = IAPManager()
	
	private init() {
		//var tempArrayForContentsOfDirectory = try? FileManager.default.contentsOfDirectory(atPath: download.contentURL?.path ?? "")
		
	}
	
	
}
