//
//  BasicMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 23/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class BasicMessageCell: BaseMessageCell, SizingCell {
    static let identifier = String(describing: BasicMessageCell.self)

    // MARK: SizingCell

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = BasicMessageCell.instantiateFromNib() else {
            return BasicMessageCell()
        }

        return cell
    }()

	@IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var statusView: UIImageView!
    @IBOutlet weak var text: RCTextView!

    @IBOutlet weak var readReceiptButton: UIButton!

    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    @IBOutlet var textLeadingConstraintEqual: NSLayoutConstraint!
	@IBOutlet var textLeadingConstraintGreatThenOrEqual: NSLayoutConstraint!
    @IBOutlet var textTrailingConstraintEqual: NSLayoutConstraint!
	@IBOutlet var textTrailingConstraintGreatThenOrEqual: NSLayoutConstraint!
    @IBOutlet weak var readReceiptWidthConstraint: NSLayoutConstraint!

    var textWidth: CGFloat {
		let leading = isSender
			? textLeadingConstraintGreatThenOrEqual.constant
			: textLeadingConstraintEqual.constant
		let trailing = isSender
			? textTrailingConstraintGreatThenOrEqual.constant
			: textTrailingConstraintEqual.constant
		return messageWidth -
			leading -
			trailing -
            layoutMargins.left -
            layoutMargins.right
    }
	
	private var isSender: Bool {
		get {
			guard
				let viewModel = viewModel?.base as? BasicMessageChatItem,
				let message = viewModel.message
			else {
				return false
			}
			return message.userIdentifier == AuthManager.currentUser()?.identifier
		}
	}

    override var delegate: ChatMessageCellProtocol? {
        didSet {
            text.delegate = delegate
        }
    }

    var initialTextHeightConstant: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        initialTextHeightConstant = textHeightConstraint.constant
    }
	
	private func configureConstraints() {
		if isSender {
			textLeadingConstraintEqual?.isActive = false
			textTrailingConstraintGreatThenOrEqual?.isActive = false
			textLeadingConstraintGreatThenOrEqual?.isActive = true
			textTrailingConstraintEqual?.isActive = true
		} else {
			textLeadingConstraintGreatThenOrEqual?.isActive = false
			textTrailingConstraintEqual?.isActive = false
			textLeadingConstraintEqual?.isActive = true
			textTrailingConstraintGreatThenOrEqual?.isActive = true
		}
	}

    override func configure(completeRendering: Bool) {
        configure(
            with: avatarView,
            date: date,
			status: statusView,
			and: nil,
            completeRendering: completeRendering
        )
	
        configure(readReceipt: readReceiptButton)
        updateText()
    }

    func updateText() {
        guard
            let viewModel = viewModel?.base as? BasicMessageChatItem,
            let message = viewModel.message
        else {
            return
        }
		configureConstraints()

        if let messageText = MessageTextCacheManager.shared.message(for: message, with: theme) {
            if message.temporary {
                messageText.setFontColor(MessageTextFontAttributes.systemFontColor(for: theme))
            } else if message.failed {
                messageText.setFontColor(MessageTextFontAttributes.failedFontColor(for: theme))
            }

            text.message = messageText
			text.isSender = message.userIdentifier == AuthManager.currentUser()?.identifier

            let maxSize = CGSize(
                width: textWidth,
                height: .greatestFiniteMagnitude
            )
			let height = text.textView.sizeThatFits(maxSize).height
            textHeightConstraint.constant = height
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        date.text = ""
		text.isSender = nil
        text.message = nil
        avatarView.prepareForReuse()
        textHeightConstraint.constant = initialTextHeightConstant
		textLeadingConstraintEqual?.isActive = false
		textLeadingConstraintGreatThenOrEqual?.isActive = false
		textTrailingConstraintEqual?.isActive = false
		textTrailingConstraintGreatThenOrEqual?.isActive = false
    }
}

// MARK: Theming

extension BasicMessageCell {

    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        date.textColor = theme.auxiliaryText
        updateText()
    }

}
