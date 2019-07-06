//
//  InfoSlider.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 07.07.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

class InfoSlider: UISlider {

	public let infoLable: UILabel = {
		let label = UILabel()
		label.backgroundColor = .red
		label.text = "100"
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		//guard let thumb = currentThumbImage else { return }
		addSubview(infoLable)
		NSLayoutConstraint.activate([
			infoLable.bottomAnchor.constraint(equalTo: topAnchor),
			infoLable.widthAnchor.constraint(equalToConstant: 35),
		])
	}
	
	
	override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
		let sliderFrame = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
		let centerPoint = CGPoint(x: sliderFrame.origin.x + frame.origin.x, y: frame.origin.y - 20)
		//print(centerPoint)
		infoLable.text = String(Int(value * 100))
		infoLable.center = centerPoint
		print(infoLable.frame.origin.x)
		
		return sliderFrame
	}
	

}
