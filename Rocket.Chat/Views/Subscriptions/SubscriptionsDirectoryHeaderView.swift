//
//  SubscriptionsDirectoryHeaderView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 07/05/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit

final class SubscriptionsDirectoryHeaderView: UIView {
    override var theme: Theme? {
        guard let theme = super.theme else { return nil }
        return Theme(
            backgroundColor: theme.appearence == .light ? theme.backgroundColor : theme.focusedBackground,
            focusedBackground: theme.focusedBackground,
            chatComponentBackground: theme.chatComponentBackground,
            auxiliaryBackground: theme.auxiliaryBackground,
            bannerBackground: theme.bannerBackground,
            titleText: theme.titleText,
            bodyText: theme.bodyText,
			senderText: theme.senderText,
			receiverText: theme.receiverText,
            borderColor: theme.borderColor,
            controlText: theme.controlText,
            auxiliaryText: theme.auxiliaryText,
            tintColor: theme.tintColor,
			greenColor: theme.greenColor,
            auxiliaryTintColor: theme.auxiliaryTintColor,
            actionTintColor: theme.actionTintColor,
            actionBackgroundColor: theme.actionBackgroundColor,
            mutedAccent: theme.mutedAccent,
			strongAccent: theme.strongAccent,
			gradientColors: theme.gradientColors,
            appearence: theme.appearence
        )
    }
}
