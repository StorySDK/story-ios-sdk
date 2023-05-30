//
//  QuizMultipleAnswerView.swift
//  StorySDK
//
//  Created by Igor Efremov on 19.05.2023.
//

import UIKit

final class QuizMultipleAnswerView: SRInteractiveWidgetView {
    let widget: SRQuizOneAnswerWidget
    
    private let headerLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        
        return lbl
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
        headerLabel.font = .font(family: widget.titleFont.fontFamily,
                                 ofSize: 12.0 * scale, weight: UIFont.Weight(widget.titleFont.fontParams.weight))
        headerLabel.frame = .init(x: 0, y: 0, width: bounds.width, height: 41 * scale)
        gradientLayer.frame = headerLabel.frame
        answersView.frame = .init(x: 0, y: headerLabel.frame.maxY, width: bounds.width, height: max(0, bounds.height - headerLabel.frame.maxY))
        var frame = answersView.bounds
        let padding: CGFloat = 22//12 * scale
        let spacing: CGFloat = 4 //6 * scale
        guard frame.height > padding * 2, !answerViews.isEmpty else { return }
        frame = frame.insetBy(dx: padding, dy: padding)
        var height = frame.height
        height -= spacing * CGFloat(answerViews.count - 1)
        height = 34///= CGFloat(answerViews.count)
        guard height > 0 else { return }
        
        let fontWeight = widget.answersFont.fontParams.weight
        let fontSize = (10 * scale).rounded()
        let font = UIFont.font(family: widget.answersFont.fontFamily,
                         ofSize: fontSize, weight: .init(rawValue: fontWeight))
        
        var innerIndex = 0
        var y = frame.minY
        var x = frame.minX
        
        for i in 0..<answerViews.count {
            answerViews[i].font = font
//            answerViews[i].frame = .init(
//                x: frame.minX,
//                y: frame.minY + (height + spacing) * CGFloat(i),
//                width: frame.width,
//                height: height
//            )
            
            x =  CGFloat(innerIndex * (140 + 8)) //frame.minX + CGFloat(innerIndex * (140 + 8))
            if x + 140 > frame.maxX {
                y += (height + spacing)
                x = 0//frame.minX
                innerIndex = 0
            }
            
            answerViews[i].frame = .init(
                x: x,
                y: y,
                width: 140,
                height: height
            )
            
            innerIndex += 1
            
//            answerViews[i].frame = .init(
//                x: frame.minX + CGFloat(i * (140 + 8)),
//                y: frame.minY, //+ (height + spacing) * CGFloat(i),
//                width: /*frame.width*/140,
//                height: height
//            )
        }
    }
    
    func selectAnswer(_ id: String) {
        var hasValue = false
        for view in answerViews {
            let currentId = view.answer.id
            if currentId == id {
                view.wasSelected = true
            }
            // TODO
//            view.status = currentId == widget.correct ? .valid : .invalid
//            hasValue = hasValue || view.wasSelected
        }
        isUserInteractionEnabled = !hasValue
    }
    
    @objc func answerClicked(_ sender: EmojiAnswerView) {
        UIView.animate(withDuration: 0.35) {
            sender.backgroundColor = .black
            sender.wasSelected = true
        }
        
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
