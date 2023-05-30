//
//  EmojiAnswerView.swift
//  StorySDK
//
//  Created by Igor Efremov on 29.05.2023.
//

import UIKit

final class EmojiAnswerView: UIButton {
    enum Status { case valid, invalid, undefined }
    
    private var emojiViews = [UIImageView]()

    private let textLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        
        return lbl
    }()
    
    var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    var font: UIFont? {
        didSet {
            textLabel.font = font ?? .regular(ofSize: 10.0)
        }
    }

    let answer: SRAnswerValue
    let scale: CGFloat
    
    var wasSelected: Bool = false {
        didSet {
            textLabel.textColor = wasSelected ? .white : SRThemeColor.black.color
        }
    }

    init(answer: SRAnswerValue, scale: CGFloat) {
        self.answer = answer
        self.scale = scale
        super.init(frame: CGRect.zero)
        prepareUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        
        let sz = emojiViews.first?.image?.size ?? CGSize.zero
        
        emojiViews.first?.frame = CGRect(x: 4, y: Int(bounds.height - sz.height) / 2, width: Int(sz.width), height: Int(sz.height))

        textLabel.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: bounds.width, height: bounds.height))
    }

    private func prepareUI() {
        backgroundColor = .white
        addSubview(textLabel)
    
        if let emoji = answer.emoji?.unicode {
            if let result = UInt32(emoji, radix: 16),
               let str = UnicodeScalar(result).map({ String($0) }) {
                textLabel.text = String(format: "%@  %@", str, answer.title)
            }
        }
        
        textLabel.textColor = SRThemeColor.black.color
    }
}
