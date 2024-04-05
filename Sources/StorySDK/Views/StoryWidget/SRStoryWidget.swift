//
//  SRStoryWidget.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

#if os(macOS)
    import Cocoa

    public final class SRStoryWidget: StoryView {
        private let viewModel: SRGroupsViewModel
        
        public init(dataStorage: SRDefaultGroupsDataStorage) {
            self.viewModel = .init(dataStorage: dataStorage)
            super.init(frame: .zero)
        }
        
        public convenience init(sdk: StorySDK = .shared) {
            let dataStorage = SRDefaultGroupsDataStorage(sdk: sdk)
            self.init(dataStorage: dataStorage)
        }
        
        required init?(coder: NSCoder) {
            let dataStorage = SRDefaultGroupsDataStorage(sdk: .shared)
            self.viewModel = .init(dataStorage: dataStorage)
            super.init(coder: coder)
        }
    }
#elseif os(iOS)
    import UIKit

    @IBDesignable
    public final class SRStoryWidget: StoryView {
        public override var intrinsicContentSize: CGSize {
    #if TARGET_INTERFACE_BUILDER
            .init(width: CGFloat.greatestFiniteMagnitude, height: 118)
    #else
            if isLoading || viewModel.numberOfItems > 0 {
                return .init(
                    width: CGFloat.greatestFiniteMagnitude,
                    height: layout.itemSize.height + contentInset.top + contentInset.bottom
                )
            } else {
                return .init(
                    width: CGFloat.greatestFiniteMagnitude,
                    height: CGFloat.leastNonzeroMagnitude
                )
            }
    #endif
        }
        public override var tintColor: UIColor! {
            didSet { loadingIndicator.tintColor = tintColor }
        }
        public var contentInset: UIEdgeInsets {
            get { collectionView.contentInset }
            set {
                collectionView.contentInset = newValue
                invalidateIntrinsicContentSize()
            }
        }
        public var onErrorReceived: ((Error) -> Void)?
        private var isLoading: Bool = false {
            didSet {
                if isLoading {
                    loadingIndicator.startAnimating()
                } else {
                    loadingIndicator.stopAnimating()
                }
            }
        }
        private let viewModel: SRGroupsViewModel
        private let layout: UICollectionViewFlowLayout = {
            let l = UICollectionViewFlowLayout()
            l.scrollDirection = .horizontal
            return l
        }()
        private let loadingIndicator: UIActivityIndicatorView = {
            let v = UIActivityIndicatorView(style: .medium)
            v.hidesWhenStopped = true
            return v
        }()
        private lazy var collectionView: UICollectionView = {
            let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
            v.contentInset = .init(top: 14, left: 14, bottom: 14, right: 14)
            v.register(viewModel.cellClass, forCellWithReuseIdentifier: "StoryCell")
            v.showsHorizontalScrollIndicator = false
            v.backgroundColor = .clear
            v.contentInsetAdjustmentBehavior = .never
            return v
        }()
        public weak var delegate: SRStoryWidgetDelegate?
        
        private var skeletonShown: [Int: Bool] = [:]
        
        public init(dataStorage: SRDefaultGroupsDataStorage) {
            self.viewModel = .init(dataStorage: dataStorage)
            super.init(frame: .zero)
            setupLayout()
            bindView()
        }
        
        public convenience init(sdk: StorySDK = .shared) {
            let dataStorage = SRDefaultGroupsDataStorage(sdk: sdk)
            self.init(dataStorage: dataStorage)
        }
        
        required init?(coder: NSCoder) {
            let dataStorage = SRDefaultGroupsDataStorage(sdk: .shared)
            self.viewModel = .init(dataStorage: dataStorage)
            super.init(coder: coder)
            viewModel.setupLayout(layout)
            setupLayout()
            bindView()
        }
        
    #if TARGET_INTERFACE_BUILDER
        public override func draw(_ rect: CGRect) {
            let bounds = rect.insetBy(dx: 14, dy: 14)
            guard bounds.height > 0 else { return }
            guard let ctx = UIGraphicsGetCurrentContext() else { return }
            let amount = max(3, Int(ceil(bounds.width / 100)))
            var x = bounds.minX
            let y = bounds.minY + 90
            ctx.setFillColor(UIColor.systemBackground.cgColor)
            ctx.fill(bounds)
            ctx.setFillColor(UIColor.label.cgColor)
            for i in 0..<amount {
                ctx.fillEllipse(in: .init(x: x + 10, y: bounds.minY, width: 70, height: 70))
                ctx.fill(.init(x: x, y: y, width: 90, height: 10))
                x += 100
            }
        }
    #endif
        
        private func setupLayout() {
            for v: UIView in [loadingIndicator, collectionView] {
                addSubview(v)
                v.translatesAutoresizingMaskIntoConstraints = false
            }
            NSLayoutConstraint.activate([
                collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
                collectionView.topAnchor.constraint(equalTo: topAnchor),
                collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        }
        
        public func bindView() {
            collectionView.dataSource = self
            collectionView.delegate = self
            
            viewModel.onReloadData = { [weak self] in
                if StorySDK.shared.configuration.onboardingFilter {
                    guard let wSelf = self else { return }
                    wSelf.isLoading = false
                    wSelf.invalidateIntrinsicContentSize()
                    wSelf.viewModel.setupLayout(wSelf.layout)
                    wSelf.collectionView.reloadData()
                }
            }
            viewModel.onErrorReceived = { [weak self] error in
                guard let widget = self else { return }
                widget.isLoading = false
                widget.onErrorReceived?(error)
                
                if error is CancellationError {
                    
                } else {
                    widget.delegate?.onWidgetErrorReceived(error, widget: widget)
                }
            }
            viewModel.onPresentGroup = { [weak self] index in
                guard let widget = self else { return }
                widget.delegate?.onWidgetGroupPresent(
                    index: index,
                    groups: widget.viewModel.groups,
                    widget: widget
                )
            }
            viewModel.onGroupsLoaded = { [weak self] in
                guard let widget = self else { return }
                
                
                widget.delegate?.onWidgetGroupsLoaded(
                    groups: widget.viewModel.groups
                    )
            }
            viewModel.onMethodCall = { [weak self] selectorName in
                guard let widget = self else { return }
                widget.delegate?.onWidgetMethodCall(selectorName)
            }
            
            viewModel.onGroupClosed = { [weak self] in
                guard let widget = self else { return }
                widget.delegate?.onWidgetGroupClose()
            }
        }
        
        public func load() {
            skeletonShown.removeAll()
            viewModel.load()
            //isLoading = true
            invalidateIntrinsicContentSize()
        }
        
        public func reload() {
            viewModel.reload()
            //isLoading = true
            invalidateIntrinsicContentSize()
        }
        
        public func openAsOnboarding(groupId: String) {
            guard let groupIndex = (viewModel.dataStorage.groups.firstIndex(where: { $0.id == groupId })) else { return }
            viewModel.onPresentGroup?(groupIndex)
        }
    }

    extension SRStoryWidget: UICollectionViewDataSource {
        public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            viewModel.numberOfItems
        }
        
        public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let reusable = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath)
            guard let cell = reusable as? SRGroupsCollectionCell else {
                return reusable
            }
            
            viewModel.setupCell(cell, index: indexPath.row)
            
            if !(skeletonShown[indexPath.row] ?? false) {
                cell.makeSkeletonCell()
                skeletonShown[indexPath.row] = true
            }
            
            return cell
        }
    }

    extension SRStoryWidget: UICollectionViewDelegate {
        public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            viewModel.didTap(index: indexPath.row)
        }
    }

    extension UICollectionViewFlowLayout: SRGroupsLayout {
        public func updateSpacing(_ spacing: CGFloat) {
            minimumLineSpacing = spacing
            minimumInteritemSpacing = spacing
        }
        
        public func updateItemSize(_ size: CGSize) {
            itemSize = size
        }
    }

    extension UIView {
        func setGradientBackground(top: UIColor, bottom: UIColor) {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [bottom.cgColor, top.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.locations = [0, 1]
            gradientLayer.frame = bounds

            layer.insertSublayer(gradientLayer, at: 0)
        }
        
        func removeSkeleton() {
            self.layer.removeAnimation(forKey: "opacity")
        }
        
        func makeSkeleton() {
            let liteColor = UIColor.parse(rawValue: "#DADADA")!
            
            let color = liteColor
            self.layer.removeAllAnimations()
            self.layer.opacity = 0.25
            let animation = CAKeyframeAnimation(keyPath: "opacity")
            animation.values         = [0.25, 0.4]
            animation.keyTimes       = [0, 1]
            animation.duration       = 1
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.repeatCount    = Float.infinity
            animation.autoreverses   = true
            self.layer.add(animation, forKey: "opacity")
            self.layer.sublayers?.forEach { $0.opacity = 0 }
            switch self {
            case let label as UILabel:
                label.textColor = .clear
                
                // TODO: Check & remove it
                
    //            let layer: CALayer = {
    //                if let l = label.layer.sublayers?.first(where: { $0.cornerRadius == 8 }) {
    //                    return l
    //                }
    //                let layer = CALayer()
    //                label.layer.addSublayer(layer)
    //                return layer
    //            }()
                
                //layer.opacity = 0.25
    //            layer.cornerRadius = 8
    //            layer.masksToBounds = true
                label.layer.backgroundColor = color.cgColor
                label.layer.frame = CGRect(origin: /*.zero*/CGPoint(x: /*(90 - 68) / 2*/13, y: 0.0), size: CGSize(width: 68, height: 18.0))
                
                //label.layer.backgroundColor = color.cgColor
                label.layer.cornerRadius = 8
                label.layer.masksToBounds = true
            case let image as UIImageView:
                if let content = image.image {
                    image.image = nil//= content.tintImage(color)
                    image.backgroundColor = liteColor//.gray//.clear
                } else {
                    image.image = nil
                    image.layer.cornerRadius = 5
                    image.layer.masksToBounds = true
                    image.backgroundColor = liteColor//color
                }
            case let textField as UITextField:
                textField.rightView = nil
                textField.leftView = nil
                textField.textColor = color
                textField.layer.cornerRadius = 5
                textField.layer.masksToBounds = true
                textField.backgroundColor = color
            case let stackView as UIStackView:
                stackView.subviews.forEach { $0.removeFromSuperview() }
                fallthrough
            default:
                self.subviews.forEach { $0.isHidden = true }
                self.layer.cornerRadius = 5
                self.layer.masksToBounds = true
                self.backgroundColor = color
            }
        }
    }

    extension UIImage {
        func tintImage(_ tintColor: UIColor?) -> UIImage? {
            guard let tintColor = tintColor else { return self }
            
            UIGraphicsBeginImageContextWithOptions(self.size, false, StoryScreen.screenScale)
            
            guard let context = UIGraphicsGetCurrentContext() else { return self }
            let imageRect = CGRect(origin: .zero, size: size)
            
            context.saveGState()
            context.setBlendMode(.multiply)
            context.setFillColor(tintColor.cgColor)
            context.fill(imageRect)
            
            self.draw(in: imageRect, blendMode: .destinationIn, alpha: 1)
            
            context.restoreGState()
            
            let outputImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return outputImage
        }
    }
#endif

public protocol SRStoryWidgetDelegate: AnyObject {
    func onWidgetErrorReceived(_ error: Error, widget: SRStoryWidget)
    func onWidgetGroupPresent(index: Int, groups: [SRStoryGroup], widget: SRStoryWidget)
    func onWidgetGroupsLoaded(groups: [SRStoryGroup])
    func onWidgetGroupClose()
    func onWidgetMethodCall(_ selectorName: String?)
}

public extension SRStoryWidgetDelegate {
    func onWidgetErrorReceived(_ error: Error, widget: SRStoryWidget) {
        logger.error(error)
    }
}
