//
//  SRStoryCanvasView.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

struct WidgetLayout {
    var size: CGSize
    var position: CGPoint
}

#if os(macOS)
    import Cocoa

    final class SRStoryCanvasView: StoryView {
        
        init(needShowTitle: Bool = false) {
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func startConfetti() {
            
        }
        
        func didWidgetLoad(_ widget: SRInteractiveWidgetView) {
            
        }
    }
#elseif os(iOS)
    import UIKit

    final class SRStoryCanvasView: StoryView {
        private let containerView: UIView = {
            let v = UIView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.backgroundColor = .clear // .blue.withAlphaComponent(0.3)
            v.backgroundColor = .clear
            return v
        }()
        private var topOffset: NSLayoutConstraint!
        private var layoutRects: [SRWidgetView: CGRect] = [:]
        private var loadingWidgets: [SRWidgetView: Bool] = [:]
        
        var keyboardHeight: CGFloat = 0
        var needShowTitle: Bool = false {
            didSet {
                topOffset.constant = 0// needShowTitle ? 59 : 0
            }
        }
        
        var readyToShow: Bool {
            return loadingWidgets.allSatisfy {$0.value == true}
        }
        var timer: Timer? {
            didSet {
                oldValue?.invalidate()
                timer?.fire()
            }
        }
        
        init(needShowTitle: Bool = false) {
            self.needShowTitle = needShowTitle
            super.init(frame: .zero)
            setupLayout()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func appendWidget(_ widget: SRWidgetView, position: CGRect) {
            containerView.addSubview(widget)
            loadingWidgets[widget] = widget.loaded
            layoutRects[widget] = position
        }
        
        func widgets() -> [SRWidgetView]? {
            containerView.subviews.filter { $0.isKind(of: SRWidgetView.self) } as? [SRWidgetView]
        }
        
        func cleanCanvas() {
            containerView.subviews.forEach { $0.removeFromSuperview() }
            layoutRects = [:]
        }
        
        func startConfetti() {
            let v = ConfettiView(frame: bounds)
            addSubview(v)
            v.startConfetti()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                v.stopConfetti()
                v.removeFromSuperview()
            }
        }
        
        func didWidgetLoad(_ widget: SRInteractiveWidgetView) {
            loadingWidgets[widget] = true
            
            setNeedsLayout()
            layoutIfNeeded()
        }
        
        private func setupLayout() {
            addSubview(containerView)
            topOffset = containerView.topAnchor.constraint(equalTo: topAnchor)
            NSLayoutConstraint.activate([
                topOffset,
                containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                containerView.rightAnchor.constraint(equalTo: rightAnchor),
                containerView.leftAnchor.constraint(equalTo: leftAnchor),
            ])
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let frame = CGRect(origin: .zero,
                               size: CGSize(width: containerView.bounds.width,
                                            height: containerView.bounds.height))
            if readyToShow {
                for (view, rect) in layoutRects {
                    let transform = view.transform
                    view.transform = .identity
                    
                    
                    var h: CGFloat
                    if !view.data.positionLimits.isResizableY {
                        let positionRes: SRPosition?
                        if CGSize.isSmallStories() {
                            h = view.data.positionByResolutions.res360x640!.realHeight
                        } else {
                            h = view.data.positionByResolutions.res360x780!.realHeight
                        }
                    } else {
                        h = round(frame.height * rect.height)
                    }
                    
                    var size = CGSize(
                        width: frame.width * rect.width,
                        height: h
                    )
                    size = view.sizeThatFits(size)
                    let origin = CGPoint(
                        x: frame.width * rect.origin.x,
                        y: frame.height * rect.origin.y
                    )
                    
                    view.frame = .init(origin: origin, size: size)
                    view.transform = transform
                }
            }
        }
    }
#endif
