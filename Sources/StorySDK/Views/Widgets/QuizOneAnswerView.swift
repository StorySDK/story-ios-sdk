//
//  QuizOneAnswerView.swift
//  StorySDK
//
//  Created by Igor Efremov on 14.05.2023.
//

#if os(macOS)
    import Cocoa

    final class QuizOneAnswerView: SRInteractiveWidgetView {
        let widget: SRQuizOneAnswerWidget
        
        init(story: SRStory, data: SRWidget, widget: SRQuizOneAnswerWidget) {
            self.widget = widget
            super.init(story: story, data: data)
        }
    }
#elseif os(iOS)
    import UIKit

    final class QuizOneAnswerView: SRInteractiveWidgetView {
        let widget: SRQuizOneAnswerWidget
        
        private var disabledWidget: Bool = false
        
        private let headerLabel: UILabel = {
            let lb = UILabel()
            lb.font = .bold(ofSize: 12)
            lb.textAlignment = .center
            return lb
        }()
        
        private let answersView: UIView = {
            let v = UIView()
            v.backgroundColor = .clear
            //v.isUserInteractionEnabled = true
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
            
            self.loaded = true
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
        
        func selectAnswer(_ id: String, score: SRScore?) {
            var hasValue = false
            for view in answerViews {
                let currentId = view.answer.id
                view.wasSelected = currentId == id
            }
            isUserInteractionEnabled = !hasValue
            
            delegate?.didChooseOneAnswer(self, answer: id, score: score)
        }
        
        @objc func answerClicked(_ sender: EmojiAnswerView) {
            guard !disabledWidget else { return }
            
            let answer = sender.answer
            let id = answer.id
             
            selectAnswer(id, score: answer.score)
            
            UIView.animate(withDuration: 0.35) {
                sender.backgroundColor = .black
                sender.wasSelected = true
            }
            
            disabledWidget = true
        }
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            let scale = widgetScale
            var height: CGFloat = 41 * scale
            let padding: CGFloat = 12 * scale
            let spacing: CGFloat = 6 * scale
            height += padding * 2
            height += CGFloat(max(0, answerViews.count - 1)) * spacing
            height += CGFloat(answerViews.count) * 34 * scale
            
            return CGSize(width: size.width, height: height/*max(height, size.height)*/)
            //return CGSize(width: size.width, height: min(height, size.height))
        }
        
        override func setupWidget(reaction: String) {
            //selectAnswer(reaction, score: s: 0)
        }
    }
#endif

protocol QuizOneAnswerViewDelegate: AnyObject {
    func didChooseOneAnswer(_ widget: QuizOneAnswerView, answer: String, score: SRScore?)
}

