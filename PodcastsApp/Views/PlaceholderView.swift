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
	private var tapAction:(() -> ())!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	
	convenience init (img: UIImage, title: String? = nil, onTapAction: @escaping (() -> ())) {
		self.init()
		str = title
		tapAction = onTapAction
		isUserInteractionEnabled = true
		
		mainPicture.image = #imageLiteral(resourceName: "placeholder_favorites").withRenderingMode(.alwaysTemplate)
		mainPicture.translatesAutoresizingMaskIntoConstraints = false
		mainPicture.tintColor = .lightGray
		mainPicture.isUserInteractionEnabled = true
		mainPicture.contentMode = .scaleAspectFit
		mainPicture.alpha = 0.7
		
		addSubview(mainPicture)
	}
	
	
	override func didMoveToWindow() {
		super.didMoveToWindow()
		translatesAutoresizingMaskIntoConstraints = false
		let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? TabBarController
		let tabBarHeight = tabBarVC?.tabBar.frame.size.height ?? 0
		guard let sv = superview else { return }
		
		let picWidthAnchor = NSLayoutConstraint(
			item: mainPicture,
			attribute: .width,
			relatedBy: .equal,
			toItem: sv,
			attribute: .width,
			multiplier: 0.55,
			constant: 0
		)
		NSLayoutConstraint.activate([
			mainPicture.centerXAnchor.constraint(equalTo: sv.centerXAnchor),
			mainPicture.centerYAnchor.constraint(equalTo: sv.centerYAnchor, constant: -tabBarHeight),
			mainPicture.heightAnchor.constraint(equalTo: mainPicture.widthAnchor),
			picWidthAnchor,
		])
		mainPicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelfTap)))
	}
	
	
	
	@objc private func onSelfTap() {
		//guard let function = tapAction else { return }
		tapAction()
		print("Tapped!")
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
}
