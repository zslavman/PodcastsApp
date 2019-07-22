//
//  CustomSlider.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 21.07.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit

protocol PlayerDetailsViewDelegate: class {
	func setPermissionTo(_ arg: Bool)
}

// NOT USED!!!
// this slider stops the timer while handle dragging
class CustomSlider: UISlider {
	weak var delegate: PlayerDetailsViewDelegate?

	override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		delegate?.setPermissionTo(false)
		return super.beginTracking(touch, with: event)
	}
	
	override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		super.endTracking(touch, with: event)
		delegate?.setPermissionTo(true)
	}

	override func cancelTracking(with event: UIEvent?) {
		super.cancelTracking(with: event)
		delegate?.setPermissionTo(true)
	}

}


extension CustomSlider: UIGestureRecognizerDelegate {
	
	// don't allow recognize all other gestures on slider dragging
//	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//		return false
//	}
	
//	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//		if let touchedView = touch.view, touchedView.isKind(of: UISlider.self) {
//			return false
//		}
//		return true
//	}
	
}
