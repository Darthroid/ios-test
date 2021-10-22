//
//  BaseTabBarViewController.swift
//  Rocket.Chat
//
//  Created by Oleg Komaristy on 22.10.2021.
//  Copyright © 2021 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit

class BaseTabBarViewController: UITabBarController {
	override func viewDidLoad() {
		super.viewDidLoad()
		tabBar.backgroundColor = UIColor.white

		if #available(iOS 13, *) {
			// iOS 13:
			let appearance = tabBar.standardAppearance
			appearance.configureWithOpaqueBackground()
			appearance.shadowImage = nil
			appearance.shadowColor = nil
			tabBar.standardAppearance = appearance
		} else {
			tabBar.shadowImage = UIImage()
			tabBar.backgroundImage = UIImage()
		}

		tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
		tabBar.layer.shadowRadius = 50
		tabBar.layer.shadowColor = UIColor.black.cgColor
		tabBar.layer.shadowOpacity = 0.05
	}
}
