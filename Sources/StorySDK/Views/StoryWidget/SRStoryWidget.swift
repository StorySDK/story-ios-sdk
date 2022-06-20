//
//  SRStoryWidget.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import UIKit

public protocol SRStoryWidgetDelegate: AnyObject {
    func onWidgetErrorReceived(_ error: Error, widget: SRStoryWidget)
    func onWidgetGroupPresent(_ group: StoryGroup, widget: SRStoryWidget)
}

public extension SRStoryWidgetDelegate {
    func onWidgetErrorReceived(_ error: Error, widget: SRStoryWidget) {
        print("StorySDK > Error:", error.localizedDescription)
    }
}

@IBDesignable
public final class SRStoryWidget: UIView {
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
        v.register(SRCollectionCell.self, forCellWithReuseIdentifier: "StoryCell")
        v.showsHorizontalScrollIndicator = false
        v.backgroundColor = .clear
        return v
    }()
    public weak var delegate: SRStoryWidgetDelegate?
    
    public init(sdk: StorySDK = .shared) {
        let dataSource = SRDefaultGroupsDataStorage(sdk: sdk)
        self.viewModel = .init(dataStorage: dataSource)
        super.init(frame: .zero)
        setupLayout()
        bindView()
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
            guard let wSelf = self else { return }
            wSelf.isLoading = false
            wSelf.invalidateIntrinsicContentSize()
            wSelf.viewModel.setupLayout(wSelf.layout)
            wSelf.collectionView.reloadData()
        }
        viewModel.onErrorReceived = { [weak self] error in
            guard let widget = self else { return }
            widget.isLoading = false
            widget.onErrorReceived?(error)
            widget.delegate?.onWidgetErrorReceived(error, widget: widget)
        }
        viewModel.onPresentGroup = { [weak self] group in
            guard let widget = self else { return }
            widget.delegate?.onWidgetGroupPresent(group, widget: widget)
        }
    }
    
    public func load() {
        viewModel.load()
        isLoading = true
        invalidateIntrinsicContentSize()
    }
}

extension SRStoryWidget: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reusable = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath)
        guard let cell = reusable as? SRCollectionCell else { return reusable }
        viewModel.setupCell(cell, index: indexPath.row)
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
