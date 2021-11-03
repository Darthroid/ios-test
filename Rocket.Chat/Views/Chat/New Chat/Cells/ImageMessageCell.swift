//
//  ImageMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 16/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController
import FLAnimatedImage

class ImageMessageCell: BaseImageMessageCell, SizingCell {
    static let identifier = String(describing: ImageMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = ImageMessageCell.instantiateFromNib() else {
            return ImageMessageCell()
        }

        return cell
    }()

	@IBOutlet var bubbleLeadingConstraintEqual: NSLayoutConstraint!
	@IBOutlet var bubbleLeadingConstraintGreatThenOrEqual: NSLayoutConstraint!
	@IBOutlet var bubbleTrailingConstraintEqual: NSLayoutConstraint!
	@IBOutlet var bubbleTrailingConstraintGreatThenOrEqual: NSLayoutConstraint!
	
	@IBOutlet var statusStackViewTrailing: NSLayoutConstraint!
	@IBOutlet var statusStackViewLeading: NSLayoutConstraint!
	
	@IBOutlet weak var bubbleWidth: NSLayoutConstraint!

	@IBOutlet weak var bubbleView: RCBubbleView!
	@IBOutlet weak var readStatusImageView: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var statusView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: FLAnimatedImageView! {
        didSet {
            imageView.clipsToBounds = true
        }
    }

	private var isSender: Bool {
		get {
			guard let viewModel = viewModel?.base as? ImageMessageChatItem,
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
		bubbleView.frame = bubbleView.frame.insetBy(dx: -1, dy: -1)
		bubbleView.isSender = self.isSender
		bubbleView.layer.borderWidth = 1
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
        guard let viewModel = viewModel?.base as? ImageMessageChatItem else {
            return
        }
		
		bubbleWidth.constant = messageWidth * 2 / 3
        configure(
            with: avatarView,
            date: date,
            status: statusView,
            completeRendering: completeRendering
        )
		
        if completeRendering {
            loadImage(on: imageView, startLoadingBlock: { [weak self] in
                self?.activityIndicator.startAnimating()
            }, stopLoadingBlock: { [weak self] in
                self?.activityIndicator.stopAnimating()
            })
        }
		
		self.configurateBubble()
    }

    // MARK: IBAction

    @IBAction func buttonImageHandlerDidPressed(_ sender: Any) {
        guard
            let viewModel = viewModel?.base as? ImageMessageChatItem,
            let imageURL = viewModel.imageURL
        else {
            return
        }

        delegate?.openImageFromCell(url: imageURL, thumbnail: imageView)
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

extension ImageMessageCell {
    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        bubbleView.layer.borderColor = theme.borderColor.cgColor
		date.textColor = theme.auxiliaryText
    }
}
