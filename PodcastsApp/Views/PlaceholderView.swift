//
//  PlaceholderView.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 30.06.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit


class PlaceholderView: UIView {
	
	private var mainPicture: UIImageView!
	private var str: String?
	private var tapAction:(() -> ())!
	private var centerYConstraint: NSLayoutConstraint!
	private var tabBarHeight: CGFloat = 0
	private var img:UIImage!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	
	convenience init (img: UIImage, title: String? = nil, onTapAction: @escaping (() -> ())) {
		self.init()
		self.img = img
		str = title
		tapAction = onTapAction
		isUserInteractionEnabled = true
		translatesAutoresizingMaskIntoConstraints = false
	}
	
	
	override func didMoveToWindow() {
		animateOnShow()
		guard mainPicture == nil else { return }
		super.didMoveToWindow()
		guard let sv = superview else { return }
		defineSelfConstraintsTo(sv)
		
		mainPicture = UIImageView()
		mainPicture.image = img.withRenderingMode(.alwaysTemplate)
		mainPicture.translatesAutoresizingMaskIntoConstraints = false
		mainPicture.tintColor = .lightGray
		mainPicture.isUserInteractionEnabled = true
		mainPicture.contentMode = .scaleAspectFit
		addSubview(mainPicture)

		alpha = 0.45
		
		let tabBarVC = UIApplication.shared.keyWindow?.rootViewController as? TabBarController
		tabBarHeight = tabBarVC?.tabBar.frame.size.height ?? 0
		let navBarHeight = UIApplication.shared.statusBarFrame.height
		
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
			picWidthAnchor,
			mainPicture.heightAnchor.constraint(equalTo: mainPicture.widthAnchor),
			centerYConstraint,
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
	
	
	private func defineSelfConstraintsTo(_ superView: UIView) {
		NSLayoutConstraint.activate([
			leadingAnchor.constraint(equalTo: superView.leadingAnchor),
			topAnchor.constraint(equalTo: superView.topAnchor),
			trailingAnchor.constraint(equalTo: superView.trailingAnchor),
			bottomAnchor.constraint(equalTo: superView.bottomAnchor),
		])
	}
	
	
	// rotate on appear
	private func animateOnShow() {
		let dur: TimeInterval = 0.2
		UIView.animate(withDuration: dur, animations: {
			self.transform = CGAffineTransform(rotationAngle: .pi / 20)
		}, completion: {
			(finish) in
			UIView.animate(withDuration: dur, animations: {
				self.transform = CGAffineTransform(rotationAngle: -1 * (.pi / 20))
			}, completion: {
				(finishh) in
				UIView.animate(withDuration: dur, animations: {
					self.transform = CGAffineTransform.identity
				})
			})
		})
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
