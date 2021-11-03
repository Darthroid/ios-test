//
//  FileMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 16/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

class FileMessageCell: BaseMessageCell, SizingCell {
    static let identifier = String(describing: FileMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = FileMessageCell.instantiateFromNib() else {
            return FileMessageCell()
        }

        return cell
    }()

	@IBOutlet var bubbleLeadingConstraintEqual: NSLayoutConstraint!
	@IBOutlet var bubbleLeadingConstraintGreatThenOrEqual: NSLayoutConstraint!
	@IBOutlet var bubbleTrailingConstraintEqual: NSLayoutConstraint!
	@IBOutlet var bubbleTrailingConstraintGreatThenOrEqual: NSLayoutConstraint!
	
	@IBOutlet var statusStackViewTrailing: NSLayoutConstraint!
	@IBOutlet var statusStackViewLeading: NSLayoutConstraint!
	
	@IBOutlet weak var bubbleView: RCBubbleView!
	@IBOutlet weak var readStatusImageView: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var statusView: UIImageView!
    @IBOutlet weak var fileButton: UIButton! {
        didSet {
            fileButton.titleLabel?.adjustsFontSizeToFitWidth = true
            fileButton.titleLabel?.minimumScaleFactor = 0.8
            fileButton.titleLabel?.numberOfLines = 2
        }
    }
	
	private var isSender: Bool {
		get {
			guard let viewModel = viewModel?.base as? FileMessageChatItem,
			let message = viewModel.message else {
				fatalError()
				return false
			}
			return message.userIdentifier == AuthManager.currentUser()?.identifier
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
    }
	
	private func configurateBubble() {
		bubbleView.isSender = self.isSender
		readStatusImageView.isHidden = !self.isSender
		if self.isSender {
			bubbleLeadingConstraintEqual?.isActive = false
			bubbleTrailingConstraintGreatThenOrEqual?.isActive = false
			bubbleLeadingConstraintGreatThenOrEqual?.isActive = true
			bubbleTrailingConstraintEqual?.isActive = true
			statusStackViewTrailing?.isActive = true
			statusStackViewLeading?.isActive = false
		} else {
			bubbleLeadingConstraintGreatThenOrEqual?.isActive = false
			bubbleTrailingConstraintEqual?.isActive = false
			bubbleLeadingConstraintEqual?.isActive = true
			bubbleTrailingConstraintGreatThenOrEqual?.isActive = true
			statusStackViewTrailing?.isActive = false
			statusStackViewLeading?.isActive = true
		}
	}

    override func configure(completeRendering: Bool) {
        guard let viewModel = viewModel?.base as? FileMessageChatItem else {
            return
        }

        configure(
            with: avatarView,
            date: date,
            status: statusView,
            completeRendering: completeRendering
        )
		configurateBubble()
        fileButton.setTitle("here "/*viewModel.attachment.title*/, for: .normal)
    }

    @IBAction func didTapFileButton() {
        guard let viewModel = viewModel?.base as? FileMessageChatItem else {
            return
        }

        delegate?.openFileFromCell(attachment: viewModel.attachment)
    }
	
	override func prepareForReuse() {
		super.prepareForReuse()
		bubbleLeadingConstraintEqual?.isActive = false
		bubbleLeadingConstraintGreatThenOrEqual?.isActive = false
		bubbleTrailingConstraintEqual?.isActive = false
		bubbleTrailingConstraintGreatThenOrEqual?.isActive = false
		statusStackViewTrailing?.isActive = false
		statusStackViewLeading?.isActive = false
	}
}

extension FileMessageCell {
    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        date.textColor = theme.auxiliaryText
		if isSender {
			fileButton.setTitleColor(theme.senderText, for: .normal)
		} else {
			fileButton.setTitleColor(theme.receiverText, for: .normal)
		}
//		ThemeManager.theme.senderText
//		ThemeManager.theme.receiverText
        
    }
}
