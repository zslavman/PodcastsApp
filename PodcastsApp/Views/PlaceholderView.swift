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
	private var centerYConstraint: NSLayoutConstraint!
	private var tabBarHeight: CGFloat = 0
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	
	convenience init (img: UIImage, title: String? = nil, onTapAction: @escaping (() -> ())) {
		self.init()
		str = title
		tapAction = onTapAction
		isUserInteractionEnabled = true
		
		mainPicture.image = img.withRenderingMode(.alwaysTemplate)
		mainPicture.translatesAutoresizingMaskIntoConstraints = false
		mainPicture.tintColor = .lightGray
		mainPicture.isUserInteractionEnabled = true
		mainPicture.contentMode = .scaleAspectFit
		
		alpha = 0.45
		
		addSubview(mainPicture)
	}
	
	
	override func didMoveToWindow() {
		super.didMoveToWindow()
		translatesAutoresizingMaskIntoConstraints = false
		let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? TabBarController
		tabBarHeight = tabBarVC?.tabBar.frame.size.height ?? 0
		
		guard let sv = superview else { return }
		
		let picWidthAnchor = NSLayoutConstraint(
			item: mainPicture,
			attribute: .width,
			relatedBy: .equal,
			toItem: sv,
			attribute: .width,
			multiplier: 0.5,
			constant: 0
		)
		centerYConstraint = mainPicture.centerYAnchor.constraint(equalTo: sv.centerYAnchor, constant: -tabBarHeight)
		
		NSLayoutConstraint.activate([
			mainPicture.centerXAnchor.constraint(equalTo: sv.centerXAnchor),
			mainPicture.heightAnchor.constraint(equalTo: mainPicture.widthAnchor),
			centerYConstraint,
			picWidthAnchor,
		])
		mainPicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelfTap)))
		
		if let str = str {
			addTitle(str)
		}
	}
	
	
	private func addTitle(_ str: String) {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = str
		label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
		label.textColor = .lightGray
		addSubview(label)
		
		NSLayoutConstraint.activate([
			label.centerXAnchor.constraint(equalTo: mainPicture.centerXAnchor),
			label.topAnchor.constraint(equalTo: mainPicture.bottomAnchor, constant: 0)
		])
		centerYConstraint.constant = -tabBarHeight - label.frame.height
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
