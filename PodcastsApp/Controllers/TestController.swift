//
//  TestController.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 22.08.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit


class TestController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .yellow
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Run", style: .plain, target: self,
															action: #selector(onClick))
	}
	
	@objc private func onClick() {
		let origImage = #imageLiteral(resourceName: "toApprove")
		//let origImage = #imageLiteral(resourceName: "appicon")
		print(origImage.size)
		let resizedImage = SUtils.resizeImage(origImage, firstOutSide: 64, isMin: true)
		print(resizedImage.size)
		
		if let encoded = SUtils.imageToBase64(img: resizedImage) {
			UIPasteboard.general.string = encoded
			print(encoded)
		}
	}
	
	
	
	
}
