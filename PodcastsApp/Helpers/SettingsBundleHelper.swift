//
//  SettingsBundleHelper.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 16.07.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import Foundation

class SettingsBundleHelper {
	
	static let ASSEMBLE = "assemble_string" // this key must be in Root.plist
	static let PREVIEW_IMAGE = "enabled_preference" // this key must be in Root.plist
	
	
	init() {
		setVersionAndBuildNumber()
	}
	
	// fill version in Settings.bundle
	private func setVersionAndBuildNumber() {
		let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
		let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
		let assemble = version + " (" + build + ")"
		UserDefaults.standard.set(assemble, forKey: SettingsBundleHelper.ASSEMBLE)
	}
	
}
