//
//  QuizOneAnswerView.swift
//  StorySDK
//
//  Created by Igor Efremov on 14.05.2023.
//

import UIKit

final class QuizOneAnswerView: SRInteractiveWidgetView {
    let widget: SRQuizOneAnswerWidget
    
    private let headerLabel: UILabel = {
        let lb = UILabel()
        lb.font = .bold(ofSize: 12)
        lb.textAlignment = .center
        return lb
    }()
    
    private let answersView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.startPoint = CGPoint(x: 0.0, y: 0.5)
        l.endPoint = CGPoint(x: 1.0, y: 0.5)
        l.masksToBounds = true
        return l
    }()

    private var answerViews = [EmojiAnswerView]()
    
    init(story: SRStory, data: SRWidget, widget: SRQuizOneAnswerWidget) {
        self.widget = widget
        super.init(story: story, data: data)
    }
    
    override func setupContentLayer(_ layer: CALayer) {
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        layer.masksToBounds = true
    }
    
    override func addSubviews() {
        super.addSubviews()
        
        [gradientLayer].forEach(contentView.layer.addSublayer)
        [headerLabel, answersView].forEach(contentView.addSubview)
        answerViews = widget.answers
            .enumerated()
            .map { index, answer in
                let v = EmojiAnswerView(answer: answer, scale: widgetScale)
                v.tag = index
                return v
            }
        answerViews.forEach(answersView.addSubview)
    }
    
    override func setupView() {
        super.setupView()
        switch widget.titleFont.fontColor {
        case .color(let color, _):
            headerLabel.textColor = color
        default:
            headerLabel.textColor = SRThemeColor.black.color
        }
        
        headerLabel.text = widget.title
        
        answerViews.forEach { v in
            v.addTarget(self, action: #selector(answerClicked), for: .touchUpInside)
            answersView.addSubview(v)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let scale = widgetScale
        headerLabel.font = .bold(ofSize: 12 * scale)
        headerLabel.frame = .init(x: 0, y: 0, width: bounds.width, height: 41 * scale)
        gradientLayer.frame = headerLabel.frame
        answersView.frame = .init(x: 0, y: headerLabel.frame.maxY, width: bounds.width, height: max(0, bounds.height - headerLabel.frame.maxY))
        var frame = answersView.bounds
        let padding: CGFloat = 12 * scale
        let spacing: CGFloat = 6 * scale
        guard frame.height > padding * 2, !answerViews.isEmpty else { return }
        frame = frame.insetBy(dx: padding, dy: padding)
        var height = frame.height
        height -= spacing * CGFloat(answerViews.count - 1)
        height /= CGFloat(answerViews.count)
        guard height > 0 else { return }
        
        let fontWeight = widget.answersFont.fontParams.weight
        let fontSize = (10 * scale).rounded()
        let font = UIFont.regular(ofSize: fontSize, weight: .init(rawValue: fontWeight))
        
        for i in 0..<answerViews.count {
            answerViews[i].font = font
            answerViews[i].frame = .init(
                x: frame.minX,
                y: frame.minY + (height + spacing) * CGFloat(i),
                width: frame.width,
                height: height
            )
        }
    }
    
    func selectAnswer(_ id: String) {
        var hasValue = false
        for view in answerViews {
            let currentId = view.answer.id
            view.wasSelected = currentId == id
            // TODO
//            view.status = currentId == widget.correct ? .valid : .invalid
//            hasValue = hasValue || view.wasSelected
        }
        isUserInteractionEnabled = !hasValue
    }
    
    @objc func answerClicked(_ sender: EmojiAnswerView) {
        let id = sender.answer.id
        selectAnswer(id)
        // TODO
//        if id == widget.correct {
//            animateCorrectView(id: id)
//        } else {
//            animateIncorrectView(id: id)
//        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let scale = widgetScale
        var height: CGFloat = 41 * scale
        let padding: CGFloat = 12 * scale
        let spacing: CGFloat = 6 * scale
        height += padding * 2
        height += CGFloat(max(0, answerViews.count - 1)) * spacing
        height += CGFloat(answerViews.count) * 34 * scale
        return CGSize(width: size.width, height: min(height, size.height))
    }
    
    override func setupWidget(reaction: String) {
        selectAnswer(reaction)
    }
}

// MARK: - Animations
//extension ChooseAnswerView {
//    private func animateCorrectView(id: String) {
//        UIView.animate(withDuration: .animationsDuration,
//                       animations: { [weak self] in self?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3) },
//                       completion: { [weak self] _ in
//            UIView.animate(withDuration: .animationsDuration,
//                           animations: { self?.transform = CGAffineTransform.identity },
//                           completion: { _ in self?.sendMessage(id: id) })
//        })
//    }
//
//    private func animateIncorrectView(id: String) {
//        CATransaction.begin()
//        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
//        animation.timingFunction = CAMediaTimingFunction(name: .linear)
//        animation.values = [-10, 10, -8, 8, -6, 6, -3, 3, 0]
//        animation.duration = 0.5
//        animation.isRemovedOnCompletion = true
//        layer.add(animation, forKey: "shake")
//        CATransaction.setCompletionBlock { [weak self] in self?.sendMessage(id: id) }
//        CATransaction.commit()
//    }
//
//    private func sendMessage(id: String) {
//        delegate?.didChooseAnswer(self, answer: id)
//    }
//}

// MARK: - EmojiAnswerView

final class EmojiAnswerView: UIControl {
    enum Status { case valid, invalid, undefined }
    
    private var emojiViews = [UIImageView]()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .regular(ofSize: 10)
        l.textAlignment = .center
        return l
    }()
    
    var font: UIFont? {
        didSet {
            titleLabel.font = font ?? .regular(ofSize: 10.0)
        }
    }

    let answer: SRAnswerValue
    let scale: CGFloat
    
    var wasSelected: Bool = false

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

        titleLabel.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: bounds.width, height: bounds.height))
    }

    private func prepareUI() {
        backgroundColor = .white
        addSubview(titleLabel)
    
        if let emoji = answer.emoji?.unicode {
            if let result = UInt32(emoji, radix: 16),
               let str = UnicodeScalar(result).map({ String($0) }) {
                titleLabel.text = String(format: "%@  %@", str, answer.title)
            }
        }
        
        titleLabel.textColor = SRThemeColor.black.color
    }
}
