//
//  RCBubbleView.swift
//  Rocket.Chat
//
//  Created by Igor on 02.11.2021.
//  Copyright © 2021 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit

class RCBubbleView: UIView {

	var isSender: Bool! = false {
		didSet {
			self.layoutSubviews()
		}
	}

	private var gradientLayer: CAGradientLayer?

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	private func setup() {
		self.layer.cornerRadius = 16
		self.layer.masksToBounds = true
		self.clipsToBounds = true
		if isSender {
			self.backgroundColor = .clear
			self.setGradientLayer()
		} else {
			gradientLayer?.removeFromSuperlayer()
			self.backgroundColor = theme?.receivedMessageBackground
			self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
		}
	}

	private func setGradientLayer() {
		guard isSender == true else {
			gradientLayer?.removeFromSuperlayer()
			return
		}
		let gradient: CAGradientLayer = CAGradientLayer()

		gradient.colors = theme?.gradientColors
		gradient.locations = [0.0, 1.0]
		gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
		gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
		gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.size.width, height: self.bounds.size.height)
//		gradient.cornerRadius = 16
		self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]

		self.gradientLayer?.removeFromSuperlayer()
		self.layer.insertSublayer(gradient, at: 0)
		self.gradientLayer = gradient
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		if isSender {
			self.backgroundColor = .clear
			self.setGradientLayer()
		} else {
			gradientLayer?.removeFromSuperlayer()
			self.backgroundColor = theme?.receivedMessageBackground
			self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
		}
	}
}

extension RCBubbleView {
	override func applyTheme() {
		super.applyTheme()
		guard let theme = theme else { return }
		if isSender {
			self.backgroundColor = .clear
			self.setGradientLayer()
		} else {
			gradientLayer?.removeFromSuperlayer()
			self.backgroundColor = theme.receivedMessageBackground
			self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
		}
	}
}
