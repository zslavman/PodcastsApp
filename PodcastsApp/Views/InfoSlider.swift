//
//  InfoSlider.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 07.07.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

protocol PlayerDetailsViewDelegate:class {
	func setPermissionTo(_ arg: Bool)
}

class InfoSlider: UISlider {
	
	public let infoLable: LabelForSlider = {
		let label = LabelForSlider()
		label.alpha = 0
		return label
	}()
	weak var delegate: PlayerDetailsViewDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	
	required init?(coder aDecoder: NSCoder) {
		//fatalError("init(coder:) has not been implemented")
		super.init(coder: aDecoder)
		setup()
	}
	
	
	private func setup() {
		translatesAutoresizingMaskIntoConstraints = false
		addSubview(infoLable)
	}
	
	
	private func getCurrentThumbRect() -> CGRect {
		let trackRect = self.trackRect(forBounds: bounds)
		let thumbR = thumbRect(forBounds: bounds, trackRect: trackRect, value: value)
		return thumbR
	}
	
	
	override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		delegate?.setPermissionTo(false)
		let touchPoint: CGPoint = touch.location(in: self)
		// Check if the knob is touched. Only in this case show the popup-view
		if getCurrentThumbRect().insetBy(dx: -12, dy: -12).contains(touchPoint) {
			positionAndUpdatePopupView()
			showPopupView(true)
		}
		return super.beginTracking(touch, with: event)
	}
	
	
	override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		positionAndUpdatePopupView()
		return super.continueTracking(touch, with: event)
	}
	
	
	override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		delegate?.setPermissionTo(true)
		showPopupView(false)
		super.endTracking(touch, with: event)
	}
	
	override func cancelTracking(with event: UIEvent?) {
		delegate?.setPermissionTo(true)
		showPopupView(false)
		super.cancelTracking(with: event)
	}
	
	
	private func showPopupView(_ fadeIn: Bool) {
		UIView.animate(withDuration: 0.3) {
			if fadeIn {
				self.infoLable.alpha = 1.0
			}
			else {
				self.infoLable.alpha = 0.0
			}
		}
	}
	
	
	private func positionAndUpdatePopupView() {
		let _thumbRect = getCurrentThumbRect()
		let popupRect = _thumbRect.offsetBy(dx: 0, dy: -_thumbRect.size.height * 1.5) // translate label
		infoLable.frame = popupRect.insetBy(dx: -10, dy: -5) // insert blank space (minus - increase space) in both directions
		infoLable.setValue(value)
	}
	
}



class LabelForSlider: UIView {
	
	private var str: String = "25"
	private let font = UIFont.systemFont(ofSize: 18)
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .clear
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func draw(_ rect: CGRect) {
		// Set the fill color
		#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1).setFill()
		
		// Create the path for the rounded rectangle
		let roundedRect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height * 0.8)
		let roundedRectPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: 6.0)
		
		// Create the arrow path
		let arrowPath = UIBezierPath()
		let midX = bounds.midX
		let p0 = CGPoint(x: midX, y: bounds.maxY)
		arrowPath.move(to: p0)
		arrowPath.addLine(to: CGPoint(x: midX - 10.0, y: roundedRect.maxY))
		arrowPath.addLine(to: CGPoint(x: midX + 10.0, y: roundedRect.maxY))
		arrowPath.close()
		
		// Attach the arrow path to the rounded rect
		roundedRectPath.append(arrowPath)
		
		roundedRectPath.fill()
		
		let style = NSMutableParagraphStyle()
		style.alignment = NSTextAlignment.center
		
		// Draw the text
		UIColor(white: 1, alpha: 0.8).set()
		let siz = str.size(withAttributes: [.font: font])
		let yOffset: CGFloat = (roundedRect.size.height - siz.height) / 2
		let textRect = CGRect(x: roundedRect.origin.x, y: yOffset, width: roundedRect.size.width, height: siz.height)
		str.draw(in: textRect, withAttributes: [
			.font			: font,
			.foregroundColor: UIColor.white,
			.paragraphStyle : style,
		])
	}
	
	
	public func setValue(_ val: Float) {
		str = String(Int(val * 100))
		setNeedsDisplay()
	}
	
}

