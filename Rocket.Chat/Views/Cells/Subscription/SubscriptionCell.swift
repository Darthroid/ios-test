//
//  SubscriptionCell.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/4/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class SubscriptionCell: BaseSubscriptionCell {
	enum StatusIcon {
		case sent
		case read

		var image: UIImage? {
			switch self {
			case .sent: return UIImage(named: "mstatus-sent")
			case .read: return UIImage(named: "mstatus-read")
			}
		}
	}

    static let identifier = "CellSubscription"

    @IBOutlet weak var labelLastMessage: UILabel!
    @IBOutlet weak var labelDate: UILabel!
	@IBOutlet weak var messageStatusIcon: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()

        labelDate.text = nil
        labelLastMessage.text = nil
        labelName.text = nil
    }

    override func updateSubscriptionInformation() {
        guard let subscription = subscription?.managedObject else { return }

        labelLastMessage.text = subscription.roomLastMessageText ?? localized("subscriptions.list.no_message")

        if let roomLastMessage = subscription.roomLastMessage {
			if let date = roomLastMessage.createdAt {
				labelDate.text = dateFormatted(date: date)
			} else {
				labelDate.text = nil
			}

			if roomLastMessage.userIdentifier == AuthManager.currentUser()?.identifier {
				self.messageStatusIcon.isHidden = false
				let isRead = (subscription.lastSeen ?? Date()) >= (roomLastMessage.updatedAt ?? Date())
				self.messageStatusIcon.image = isRead ? StatusIcon.read.image : StatusIcon.sent.image
			} else {
				self.messageStatusIcon.isHidden = true
			}
        } else {
            labelDate.text = nil
			messageStatusIcon.isHidden = true
        }

        super.updateSubscriptionInformation()

        setLastMessageColor()
        setDateColor()
    }

    override func updateViewForAlert(with subscription: Subscription) {
        super.updateViewForAlert(with: subscription)
        labelLastMessage.font = UIFont(name: "Montserrat-SemiBold", size: 12)
    }

    override func updateViewForNoAlert(with subscription: Subscription) {
        super.updateViewForNoAlert(with: subscription)
        labelLastMessage.font = UIFont(name: "Poppins-Medium", size: 12)
    }

    private func setLastMessageColor() {
        guard
            let theme = theme,
            let subscription = subscription?.managedObject
        else {
            return
        }

        if subscription.unread > 0 || subscription.alert {
            labelLastMessage.textColor = theme.bodyText
        } else {
            labelLastMessage.textColor = theme.auxiliaryText
        }
    }

    private func setDateColor() {
		labelDate.textColor = theme?.auxiliaryText
    }

    func dateFormatted(date: Date) -> String {
        let calendar = NSCalendar.current

        if calendar.isDateInYesterday(date) {
            return localized("subscriptions.list.date.yesterday")
        }

        if calendar.isDateInToday(date) {
            return RCDateFormatter.time(date)
        }

        return RCDateFormatter.date(date, dateStyle: .short)
    }
}

// MARK: Themeable

extension SubscriptionCell {
    override func applyTheme() {
        super.applyTheme()
        setLastMessageColor()
        setDateColor()
    }
}
