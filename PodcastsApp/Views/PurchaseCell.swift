//
//  PurchaseCell.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 15.09.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit


class PurchaseCell: UITableViewCell {
	
	
	private let descriptionText: UITextView = {
		let textView = UITextView()
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.font = UIFont.systemFont(ofSize: 18, weight: .regular)
		textView.isEditable = false
		textView.isScrollEnabled = true
		textView.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
		textView.text = "Will attempt to recover by breaking constraint <NSLayoutConstraint:0x600002c3f570 UIImageView:0x7fa1e9c0c1b0"
		return textView
	}()
	
	static func identifier() -> String {
		return "\(self.classForCoder())"
	}
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	private func setup() {
		let v1 = UIView()
		v1.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
		//v1.widthAnchor.constraint(equalToConstant: 80).isActive = true
		
		let v2 = UIView()
		v2.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
		v2.heightAnchor.constraint(equalToConstant: 20).isActive = true
		
		let vertStack1 = UIStackView(arrangedSubviews: [v1, v2])
		vertStack1.axis = .vertical
		vertStack1.spacing = 3
		vertStack1.widthAnchor.constraint(equalToConstant: 100).isActive = true
		// ------------------------------
		
		let v3 = UIView()
		v3.backgroundColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
		v3.heightAnchor.constraint(equalToConstant: 25).isActive = true
		
		let v4 = UIView()
		v4.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
		
		let vertStack2 = UIStackView(arrangedSubviews: [v3, v4])
		vertStack2.axis = .vertical
		vertStack2.spacing = 3
		vertStack2.distribution = .fill

		let third = UIView()
		third.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
		third.widthAnchor.constraint(equalToConstant: 80).isActive = true
		
		let mainHorStack = UIStackView(arrangedSubviews: [vertStack1, vertStack2, third])
		mainHorStack.axis = .horizontal
		mainHorStack.spacing = 5
		mainHorStack.distribution = .fill
		mainHorStack.isLayoutMarginsRelativeArrangement = true
		mainHorStack.layoutMargins = .init(top: 0, left: 10, bottom: 0, right: 10)
		addSubview(mainHorStack)
		mainHorStack.fillSuperView()
		// ------------------------------
		
		
	}
	
	
	
	
	
}
