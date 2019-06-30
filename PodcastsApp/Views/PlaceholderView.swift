//
//  PlaceholderView.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 30.06.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit


class PlaceholderView: UIView {
	
	private let mainPicture = UIImageView()
	private var str: String?
	private var tapAction:(() -> ())?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	
	convenience init (img: UIImage, title: String? = nil, onTapAction: (() -> ())?) {
		self.init()
		str = title
		tapAction = onTapAction
		
		mainPicture.image = #imageLiteral(resourceName: "placeholder_favorites").withRenderingMode(.alwaysTemplate)
		mainPicture.translatesAutoresizingMaskIntoConstraints = false
		mainPicture.tintColor = .lightGray
		mainPicture.isUserInteractionEnabled = true
		
		addSubview(mainPicture)
	}
	
	
	@objc private func onSelfTap() {
		guard let function = tapAction else { return }
		function()
		print("Tapped!")
	}
	
	
	override func didMoveToWindow() {
		super.didMoveToWindow()
		translatesAutoresizingMaskIntoConstraints = false
		isUserInteractionEnabled = true
		let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? TabBarController
		let tabBarHeight = tabBarVC?.tabBar.frame.size.height ?? 0
		guard let sv = superview else { return }
		NSLayoutConstraint.activate([
			mainPicture.centerXAnchor.constraint(equalTo: sv.centerXAnchor),
			mainPicture.centerYAnchor.constraint(equalTo: sv.centerYAnchor, constant: -tabBarHeight),
			mainPicture.widthAnchor.constraint(equalToConstant: 200),
			mainPicture.heightAnchor.constraint(equalToConstant: 200),
		])
		self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelfTap)))
	}
	
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
}
