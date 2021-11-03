//
//  SequentialMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 28/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class SequentialMessageCell: BaseMessageCell, SizingCell {
    static let identifier = String(describing: SequentialMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = SequentialMessageCell.instantiateFromNib() else {
            return SequentialMessageCell()
        }

        return cell
    }()

    @IBOutlet weak var text: RCTextView!
    @IBOutlet weak var readReceiptButton: UIButton!

    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet var stackLeadingConstraintEqual: NSLayoutConstraint!
	@IBOutlet var stackLeadingConstraintGreatThenOrEqual: NSLayoutConstraint!
	@IBOutlet var stackTrailingConstraintEqual: NSLayoutConstraint!
	@IBOutlet var stackTrailingConstraintGreatThenOrEqual: NSLayoutConstraint!
    @IBOutlet weak var readReceiptWidthConstraint: NSLayoutConstraint!
    var textWidth: CGFloat {
		let leading = isSender
			? stackLeadingConstraintGreatThenOrEqual.constant
			: stackLeadingConstraintEqual.constant
		let trailing = isSender
			? stackTrailingConstraintGreatThenOrEqual.constant
			: stackTrailingConstraintEqual.constant
        return
            messageWidth -
			leading -
			trailing -
            readReceiptWidthConstraint.constant -
            layoutMargins.left -
            layoutMargins.right
    }
	
	private var isSender: Bool {
		get {
			guard
				let viewModel = viewModel?.base as? SequentialMessageChatItem,
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

        insertGesturesIfNeeded(with: nil)
    }

    override func configure(completeRendering: Bool) {
        configure(readReceipt: readReceiptButton)
        updateText()
    }
	
	private func configureConstraints() {
		if isSender {
			stackLeadingConstraintEqual?.isActive = false
			stackTrailingConstraintGreatThenOrEqual?.isActive = false
			stackLeadingConstraintGreatThenOrEqual?.isActive = true
			stackTrailingConstraintEqual?.isActive = true
		} else {
			stackLeadingConstraintGreatThenOrEqual?.isActive = false
			stackTrailingConstraintEqual?.isActive = false
			stackLeadingConstraintEqual?.isActive = true
			stackTrailingConstraintGreatThenOrEqual?.isActive = true
		}
	}

    func updateText() {
        guard
            let viewModel = viewModel?.base as? SequentialMessageChatItem,
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
        text.message = nil
		text.isSender = nil
        textHeightConstraint.constant = initialTextHeightConstant
		
		stackLeadingConstraintEqual?.isActive = false
		stackLeadingConstraintGreatThenOrEqual?.isActive = false
		stackTrailingConstraintEqual?.isActive = false
		stackTrailingConstraintGreatThenOrEqual?.isActive = false
    }
}

extension SequentialMessageCell {

    override func applyTheme() {
        super.applyTheme()
        updateText()
    }

}
