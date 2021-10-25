//
//  RCTextView.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 21.10.2017.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class HighlightLayoutManager: NSLayoutManager {
    override func fillBackgroundRectArray(_ rectArray: UnsafePointer<CGRect>, count rectCount: Int, forCharacterRange charRange: NSRange, color: UIColor) {
        let cornerRadius: CGFloat = 5
        let path = CGMutablePath.init()

        if rectCount == 1 || (rectCount == 2 && (rectArray[1].maxX < rectArray[0].maxX)) {
            path.addRect(rectArray[0].insetBy(dx: cornerRadius, dy: cornerRadius))

            if rectCount == 2 {
                path.addRect(rectArray[1].insetBy(dx: cornerRadius, dy: cornerRadius))
            }
        } else {
            let lastRect = rectCount - 1

            path.move(to: CGPoint(x: rectArray[0].minX + cornerRadius, y: rectArray[0].maxY + cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[0].minX + cornerRadius, y: rectArray[0].minY + cornerRadius))
            path.addLine(to: CGPoint(x: rectArray[0].maxX - cornerRadius, y: rectArray[0].minY + cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[0].maxX - cornerRadius, y: rectArray[lastRect].minY - cornerRadius))
            path.addLine(to: CGPoint(x: rectArray[lastRect].maxX - cornerRadius, y: rectArray[lastRect].minY - cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[lastRect].maxX - cornerRadius, y: rectArray[lastRect].maxY - cornerRadius))
            path.addLine(to: CGPoint(x: rectArray[lastRect].minX + cornerRadius, y: rectArray[lastRect].maxY - cornerRadius))

            path.addLine(to: CGPoint(x: rectArray[lastRect].minX + cornerRadius, y: rectArray[0].maxY + cornerRadius))

            path.closeSubpath()
        }

        color.set()

        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }

        ctx.setLineWidth(cornerRadius * 1.9)
        ctx.setLineJoin(.round)

        ctx.setAllowsAntialiasing(true)
        ctx.setShouldAntialias(true)

        ctx.addPath(path)
        ctx.drawPath(using: .fillStroke)
    }
}

@IBDesignable class RCTextView: UIView {

    var textView: UITextView!
    private var customEmojiViews: [EmojiView] = []

    weak var delegate: ChatMessageCellProtocol?

	var isSender: Bool!

	private var gradientLayer: CAGradientLayer?

    var message: NSAttributedString! {
        didSet {
            textView.attributedText = message
            updateCustomEmojiViews()
        }
    }

    func updateCustomEmojiViews() {
        customEmojiViews.forEach { $0.removeFromSuperview() }
        customEmojiViews.removeAll()
        addCustomEmojiIfNeeded()
    }

    func addCustomEmojiIfNeeded() {
        message?.enumerateAttributes(in: NSRange(location: 0, length: message.length), options: [], using: { attributes, crange, _ in
            if let attachment = attributes[NSAttributedString.Key.attachment] as? NSTextAttachment {
                DispatchQueue.main.async {
                    guard let position1 = self.textView.position(from: self.textView.beginningOfDocument, offset: crange.location) else { return }
                    guard let position2 = self.textView.position(from: position1, offset: crange.length) else { return }
                    guard let range = self.textView.textRange(from: position1, to: position2) else { return }

                    let rect = self.textView.firstRect(for: range)

                    let emojiView = EmojiView(frame: rect)
                    emojiView.backgroundColor = .white
                    emojiView.isUserInteractionEnabled = false
                    emojiView.applyTheme()

                    if let imageUrlData = attachment.contents,
                            let imageUrlString = String(data: imageUrlData, encoding: .utf8),
                            let imageUrl = URL(string: imageUrlString) {
                        ImageManager.loadImage(with: imageUrl, into: emojiView.emojiImageView)
                        self.customEmojiViews.append(emojiView)
                        self.addSubview(emojiView)
                    }
                }
            }
        })
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        let textStorage = NSTextStorage()
        let layoutManager = HighlightLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer.init(size: bounds.size)
        layoutManager.addTextContainer(textContainer)
        textView = UITextView.init(frame: .zero, textContainer: textContainer)
        configureTextView()

        addSubview(textView)
    }

    private func configureTextView() {
        textView.isScrollEnabled = false
        textView.adjustsFontForContentSizeCategory = true
        textView.textContainerInset = .init(top: 17, left: 20, bottom: 17, right: 20)
        textView.textContainer.lineFragmentPadding = 0
		textView.font = UIFont(name: "Montserrat-SemiBold", size: 12)
		textView.textAlignment = .center
		textView.layer.cornerRadius = 16
		textView.layer.masksToBounds = true
		textView.clipsToBounds = true
        textView.dataDetectorTypes = .all
        textView.isEditable = false
        textView.delegate = self
        textView.isAccessibilityElement = true
        textView.accessibilityTraits = .staticText
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
		gradient.cornerRadius = 16
		gradient.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner]

		self.gradientLayer?.removeFromSuperlayer()
		self.layer.insertSublayer(gradient, at: 0)
		self.gradientLayer = gradient
	}

    override func layoutSubviews() {
        super.layoutSubviews()

        textView.frame = bounds
		setGradientLayer()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        textView.text = "HighlightTextView"
    }
}

extension RCTextView: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if interaction != .invokeDefaultAction {
            return false
        }

        if URL.scheme == "http" || URL.scheme == "https" {
            delegate?.openURL(url: URL)
            return false
        }

        if let deepLink = DeepLink(url: URL) {
            switch deepLink {
            case let .mention(name):
                guard
                    let user = User.find(username: name),
                    let start = textView.position(from: textView.beginningOfDocument, offset: characterRange.location),
                    let end = textView.position(from: start, offset: characterRange.length),
                    let range = textView.textRange(from: start, to: end)
                else {
                    return false
                }

                MainSplitViewController.chatViewController?.presentActionSheetForUser(user, source: (textView, textView.firstRect(for: range)))
                return false
            default:
                return UIApplication.shared.canOpenURL(URL)
            }
        }

        return false
    }

}

// MARK: Themeable

extension RCTextView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        customEmojiViews.forEach { $0.backgroundColor = theme.backgroundColor }
		if isSender {
			textView.backgroundColor = .clear
			self.setGradientLayer()
		} else {
			gradientLayer?.removeFromSuperlayer()
			textView.backgroundColor = theme.receivedMessageBackground
			textView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
		}
    }
}
