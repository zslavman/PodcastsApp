//
//  PlaceholderView.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 30.06.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit


class PlaceholderView: UIView {
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
	}
	
	
	convenience init (img: UIImage, title: String? = nil) {
		self.init()
		
	}
	
	
	
	override func didMoveToWindow() {
		super.didMoveToWindow()
		
	}
	
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
}
