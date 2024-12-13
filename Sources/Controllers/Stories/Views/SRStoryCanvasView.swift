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
        weak var delegate: SRSizeDelegate?
        
        private let containerView: UIView = {
            let v = UIView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.backgroundColor = .clear
            return v
        }()
        private var topOffset: NSLayoutConstraint!
        private var layoutRects: [SRWidgetView: CGRect] = [:]
        private var loadingWidgets: [SRWidgetView: Bool] = [:]
        
        var keyboardHeight: CGFloat = 0
        var needShowTitle: Bool = false {
            didSet {
                topOffset.constant = needShowTitle ? 59 : 0
            }
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
            let window = UIApplication.shared.windows.first
            
            let top = 0.0//window?.safeAreaInsets.top ?? 0
            let btm = window?.safeAreaInsets.bottom ?? 0
            
            super.layoutSubviews()
            let frame = CGRect(origin: .zero,
                               size: CGSize(width: containerView.bounds.width,
                                            height: containerView.bounds.height))
            
            for (view, rect) in layoutRects {
                let transform = view.transform
                view.transform = .identity
                
                
                var h: CGFloat
                var w: CGFloat = frame.width * rect.width
                
                if !view.data.positionLimits.isResizableY || view.isKind(of: SRClickMeView.self) {
                    let sz = delegate?.getDefaultStorySize() ?? .smallStory
                    h = view.data.getWidgetPosition(storySize: sz).realHeight
                } else {
                    h = round(frame.height * rect.height)
                }
                
                if let v = view as? SRImageWidgetView {
                    if v.isVideo() {
                        h = round(frame.height * rect.height)
                    }
                }
                
                if !view.isKind(of: SRClickMeView.self) {
                    if let v = view as? SRImageWidgetView {
                        if v.imageView != nil {
                            let sz = delegate?.getDefaultStorySize() ?? .smallStory
                            let srPosition = view.data.getWidgetPosition(storySize: sz)
                            
                            if srPosition.isHeightLocked == true {
                                h = round(sz.height * rect.height)
                                w = round(sz.width * rect.width)
                            } else {
                                h = round(frame.height * rect.height)
                            }
                        }
                    }
                    
                    if let v = view as? SREllipseView {
                        let sz = delegate?.getDefaultStorySize() ?? .smallStory
                        let srPosition = view.data.getWidgetPosition(storySize: sz)
                        
                        h = round(sz.height * rect.height)
                        w = round(sz.width * rect.width)
                    }
                }

                var size = CGSize(
                    width: w,
                    height: h
                )
                size = view.sizeThatFits(size)
                let origin = CGPoint(
                    x: frame.width * rect.origin.x,
                    y: (frame.height - top) * rect.origin.y
                )
                
                view.frame = .init(origin: origin, size: size)
                view.transform = transform
            }
        }
    }
#endif
