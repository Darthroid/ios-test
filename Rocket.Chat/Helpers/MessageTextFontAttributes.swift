//
//  MessageTextFontAttributes.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 01/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

struct MessageTextFontAttributes {

	static func senderFontColor(for theme: Theme? = nil) -> UIColor {
		return theme?.senderText ?? ThemeManager.theme.senderText
	}

	static func receiverFontColor(for theme: Theme? = nil) -> UIColor {
		return theme?.receiverText ?? ThemeManager.theme.receiverText
	}

	static func messageTextColor(for theme: Theme? = nil, isSender: Bool) -> UIColor {
		return isSender ? (theme?.senderText ?? ThemeManager.theme.senderText) : (theme?.receiverText ?? ThemeManager.theme.receiverText)
	}
	
    static func defaultFontColor(for theme: Theme? = nil) -> UIColor {
        return theme?.bodyText ?? ThemeManager.theme.bodyText
    }

    static func systemFontColor(for theme: Theme? = ThemeManager.theme) -> UIColor {
        return theme?.auxiliaryText ?? ThemeManager.theme.auxiliaryText
    }

    static func failedFontColor(for theme: Theme? = ThemeManager.theme) -> UIColor {
        return theme?.auxiliaryText ?? ThemeManager.theme.auxiliaryText
    }

    static var defaultFont: UIFont {
		return UIFont(name: "Montserrat-SemiBold", size: 12) ?? .systemFont(ofSize: 12, weight: .semibold)
    }

    static var italicFont: UIFont {
        let defaultFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let fontDescriptor = defaultFontDescriptor.withSymbolicTraits(.traitItalic)

        let font: UIFont

        if let fontDescriptor = fontDescriptor {
            font = UIFont(descriptor: fontDescriptor, size: 0)
        } else {
            font = UIFont.italicSystemFont(ofSize: 16)
        }

        return font
    }

    static var boldFont: UIFont {
        let defaultFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let fontDescriptor = defaultFontDescriptor.withSymbolicTraits(.traitBold)

        let font: UIFont

        if let fontDescriptor = fontDescriptor {
            font = UIFont(descriptor: fontDescriptor, size: 0)
        } else {
            font = UIFont.italicSystemFont(ofSize: 16)
        }

        return font
    }

    static var monoSpacedFont: UIFont {
        let defaultFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let fontDescriptor = defaultFontDescriptor.withSymbolicTraits(.traitMonoSpace)?.withSymbolicTraits(.traitBold)

        let font: UIFont

        if let fontDescriptor = fontDescriptor {
            font = UIFont(descriptor: fontDescriptor, size: 0)
        } else {
            font = UIFont.italicSystemFont(ofSize: 16)
        }

        return font
    }

}
