//
//  UserDefaultsData.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 19.09.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

class UserDefaultsData {
	
	private struct Strings {
		static let lastTimeUpdated = "lastTimeUpdated"
		
	}
	
	
	public static var lastTimeJSONUpdated: TimeInterval {
		get {
			if let lastTime = UserDefaults.standard.value(forKey: Strings.lastTimeUpdated) as? Int64 {
				return TimeInterval(lastTime)
			}
			return 0
		}
		set {
			UserDefaults.standard.set(Int64(newValue), forKey: Strings.lastTimeUpdated)
		}
	}
	
}
