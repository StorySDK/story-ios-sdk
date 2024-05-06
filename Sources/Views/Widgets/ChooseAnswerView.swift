//
//  ChooseAnswerView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

#if os(macOS)
    import Cocoa

    final class ChooseAnswerView: SRInteractiveWidgetView {
        let chooseAnswerWidget: SRChooseAnswerWidget
        
        init(story: SRStory, data: SRWidget, chooseAnswerWidget: SRChooseAnswerWidget) {
            self.chooseAnswerWidget = chooseAnswerWidget
            super.init(story: story, data: data)
        }
    }
#elseif os(iOS)
    import UIKit

    final class ChooseAnswerView: SRInteractiveWidgetView {
        let chooseAnswerWidget: SRChooseAnswerWidget
        
        private let headerLabel: UILabel = {
            let lb = UILabel()
            lb.font = .bold(ofSize: 12)
            lb.textAlignment = .center
            return lb
        }()
        
        private let answersView: UIView = {
            let v = UIView()
            v.backgroundColor = .white
            //v.isUserInteractionEnabled = false
            return v
        }()
        
        private let gradientLayer: CAGradientLayer = {
            let l = CAGradientLayer()
            l.startPoint = CGPoint(x: 0.0, y: 0.5)
            l.endPoint = CGPoint(x: 1.0, y: 0.5)
            l.masksToBounds = true
            return l
        }()
        
        private var answerViews = [AnswerView]()
        
        init(story: SRStory, defaultStorySize: CGSize, data: SRWidget, chooseAnswerWidget: SRChooseAnswerWidget) {
            self.chooseAnswerWidget = chooseAnswerWidget
            super.init(story: story, defaultStorySize: defaultStorySize, data: data)
        }
        
        override func setupContentLayer(_ layer: CALayer) {
            layer.cornerRadius = 10
            layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = .zero
            layer.shadowRadius = 4
            layer.masksToBounds = true
        }
        
        //private var ans: AnswerView?
        //var btn: UIButton?
        
        override func addSubviews() {
            super.addSubviews()
            
            //ans = AnswerView(answer: chooseAnswerWidget.answers.first!)
            
            //contentView.isUserInteractionEnabled = false
            
            [gradientLayer].forEach(contentView.layer.addSublayer)
            [headerLabel, answersView].forEach(contentView.addSubview)
            answerViews = chooseAnswerWidget.answers
                .enumerated()
                .map { index, answer in
                    let v = AnswerView(answer: answer)
                    v.tag = index
                    return v
                }
            answerViews.forEach(contentView.addSubview)
            
            //[btn!].forEach(contentView.addSubview)
        }
        
        override func setupView() {
            super.setupView()
            let theme = chooseAnswerWidget.color ?? .white
            gradientLayer.colors = theme.gradient.map(\.cgColor)
            if case .white = theme {
                headerLabel.textColor = SRThemeColor.black.color
    //        } else {
                headerLabel.textColor = SRThemeColor.white.color
            }
            headerLabel.text = chooseAnswerWidget.text.uppercased()
            
            answerViews.forEach { v in
                v.addTarget(self, action: #selector(answerClicked), for: .touchUpInside)
                //v.addTarget(self, action: #selector(answerClicked), for: .valueChanged)
                answersView.addSubview(v)
            }
            
            loaded = true
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
            for i in 0..<answerViews.count {
                answerViews[i].fontSize = 10 * scale
                answerViews[i].frame = .init(
                    x: frame.minX,
                    y: frame.minY + (height + spacing) * CGFloat(i),
                    width: frame.width,
                    height: height
                )
            }
            
            //btn?.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 200))
        }
        
        func selectAnswer(_ id: String) {
            var hasValue = false
            for view in answerViews {
                let currentId = view.answer.id
                view.wasSelected = currentId == id
                view.status = currentId == chooseAnswerWidget.correct ? .valid : .invalid
                hasValue = hasValue || view.wasSelected
            }
            isUserInteractionEnabled = !hasValue
        }
        
        func selectAnswerIndex(_ index: Int) {
            var hasValue = false
    //        for view in answerViews {
    //            let currentId = view.answer.id
    //            view.wasSelected = currentId == id
    //            view.status = currentId == chooseAnswerWidget.correct ? .valid : .invalid
    //            hasValue = hasValue || view.wasSelected
    //        }
    //        isUserInteractionEnabled = !hasValue
        }
        
        @objc func answerClicked(_ sender: AnswerView) {
            let answer = sender.answer
            let id = answer.id
            
            selectAnswer(id)
            if id == chooseAnswerWidget.correct {
                animateCorrectView(id: id, score: answer.score)
            } else {
                animateIncorrectView(id: id, score: answer.score)
            }
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
    extension ChooseAnswerView {
        private func animateCorrectView(id: String, score: SRScore?) {
            UIView.animate(withDuration: SRConstants.animationsDuration,
                           animations: { [weak self] in self?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3) },
                           completion: { [weak self] _ in
                UIView.animate(withDuration: SRConstants.animationsDuration,
                               animations: { self?.transform = CGAffineTransform.identity },
                               completion: { _ in self?.sendMessage(id: id, score: score) })
            })
        }
        
        private func animateIncorrectView(id: String, score: SRScore?) {
            CATransaction.begin()
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.values = [-10, 10, -8, 8, -6, 6, -3, 3, 0]
            animation.duration = 0.5
            animation.isRemovedOnCompletion = true
            layer.add(animation, forKey: "shake")
            CATransaction.setCompletionBlock { [weak self] in self?.sendMessage(id: id, score: score) }
            CATransaction.commit()
        }

        private func sendMessage(id: String, score: SRScore?) {
            delegate?.didChooseAnswer(self, answer: id, score: score)
        }
    }

    // MARK: - AnswerView

    final class AnswerView: UIButton {
        enum Status { case valid, invalid, undefined }
        private let idContainer: UIView = {
            let v = UIView(frame: .zero)
            v.layer.borderWidth = 1
            //v.isUserInteractionEnabled = false
            return v
        }()
        private let idIconView: UIImageView = {
            let v = UIImageView()
            v.contentMode = .scaleAspectFit
            //v.isUserInteractionEnabled = false
            return v
        }()
        private let idLabel: UILabel = {
            let l = UILabel()
            l.font = .regular(ofSize: 10)
            l.textAlignment = .center
            l.textColor = SRThemeColor.black.color
            //l.isUserInteractionEnabled = false
            return l
        }()
        
        private let titleLabel2: UILabel = {
            let l = UILabel()
            l.font = .regular(ofSize: 10)
            l.textAlignment = .left
            //l.isUserInteractionEnabled = false
            return l
        }()
        
        var fontSize: CGFloat = 10 {
            didSet {
                idLabel.font = .regular(ofSize: fontSize)
                titleLabel2.font = .regular(ofSize: fontSize)
            }
        }

        let answer: SRAnswerValue
        var status: Status = .undefined {
            didSet { updateStatus() }
        }
        var wasSelected: Bool = false

        init(answer: SRAnswerValue) {
            self.answer = answer
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
            let iconHeight = bounds.height * 0.53
            let iconOffset = (bounds.height - iconHeight) / 2
            idContainer.frame = .init(x: iconOffset, y: iconOffset, width: iconHeight, height: iconHeight)
            idContainer.layer.cornerRadius = iconHeight / 2
            
            idLabel.frame = idContainer.bounds.insetBy(dx: 3, dy: 3)
            idIconView.frame = idLabel.frame
            
            let x = idContainer.frame.maxX + 8
            titleLabel2.frame = .init(x: x, y: 0, width: bounds.width - x - 8, height: bounds.height)
        }
        
        private func prepareUI() {
            backgroundColor = .clear
            layer.borderWidth = 1
            
            [idLabel, idIconView].forEach(idContainer.addSubview)
            [idContainer, titleLabel2].forEach(addSubview)
            
            idLabel.text = answer.id
            titleLabel2.text = answer.title
            
            updateStatus()
        }
        
        func updateStatus() {
            idIconView.isHidden = status == .undefined
            idLabel.isHidden = !idIconView.isHidden
            switch (status, wasSelected) {
            case (.valid, _):
                backgroundColor = SRThemeColor.green.color
                idIconView.image = .init(systemName: "checkmark")
                idContainer.layer.borderColor = SRThemeColor.white.cgColor
                idContainer.backgroundColor = SRThemeColor.green.color
                idIconView.tintColor = SRThemeColor.white.color
                titleLabel2.textColor = SRThemeColor.white.color
                layer.borderColor = SRThemeColor.green.cgColor
            case (.invalid, true):
                backgroundColor = SRThemeColor.red.color
                idIconView.image = .init(systemName: "xmark")
                idContainer.layer.borderColor = SRThemeColor.white.cgColor
                idContainer.backgroundColor = SRThemeColor.white.color
                idIconView.tintColor = SRThemeColor.red.color
                titleLabel2.textColor = SRThemeColor.white.color
                layer.borderColor = SRThemeColor.red.cgColor
            case (.invalid, false):
                backgroundColor = SRThemeColor.white.color
                idIconView.image = .init(systemName: "xmark")
                idContainer.layer.borderColor = SRThemeColor.red.cgColor
                idContainer.backgroundColor = SRThemeColor.white.color
                idIconView.tintColor = SRThemeColor.red.color
                titleLabel2.textColor = SRThemeColor.black.color
                layer.borderColor = SRThemeColor.grey.cgColor
            case (.undefined, _):
                backgroundColor = SRThemeColor.white.color
                idIconView.image = nil
                idContainer.layer.borderColor = SRThemeColor.black.cgColor
                idContainer.backgroundColor = SRThemeColor.white.color
                titleLabel2.textColor = SRThemeColor.black.color
                layer.borderColor = SRThemeColor.grey.cgColor
            }
        }
    }
#endif

protocol ChooseAnswerViewDelegate: AnyObject {
    func didChooseAnswer(_ widget: ChooseAnswerView, answer: String, score: SRScore?)
}
