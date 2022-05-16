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
        print("StoryKit > Error:", error.localizedDescription)
    }
}

public class SRStoryWidget: UIView {
    public override var intrinsicContentSize: CGSize {
        .init(width: CGFloat.greatestFiniteMagnitude,
              height: layout.itemSize.height + contentInset.top + contentInset.bottom)
    }
    public var contentInset: UIEdgeInsets {
        get { collectionView.contentInset }
        set {
            collectionView.contentInset = newValue
            invalidateIntrinsicContentSize()
        }
    }
    public var onErrorReceived: ((Error) -> Void)? {
        get { viewModel.onErrorReceived }
        set { viewModel.onErrorReceived = newValue }
    }
    private let viewModel: SRStoryViewModel
    private let layout = UICollectionViewFlowLayout()
    private lazy var collectionView: UICollectionView = {
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.contentInset = .init(top: 14, left: 14, bottom: 14, right: 14)
        v.register(SRCollectionCell.self, forCellWithReuseIdentifier: "StoryCell")
        return v
    }()
    public weak var delegate: SRStoryWidgetDelegate?
    
    public init(dataStorage: SRStoryDataStorage = SRDefaultStoryDataStorage(sdk: .shared)) {
        self.viewModel = .init(dataStorage: dataStorage)
        super.init(frame: .zero)
        setupLayout()
        bindView() 
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    public func bindView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        viewModel.onReloadData = { [weak self] in
            guard let wSelf = self else { return }
            wSelf.viewModel.setupLayout(wSelf.layout)
            wSelf.invalidateIntrinsicContentSize()
            wSelf.collectionView.reloadData()
        }
        viewModel.onErrorReceived = { [weak self] error in
            guard let widget = self else { return }
            widget.delegate?.onWidgetErrorReceived(error, widget: widget)
        }
    }
    
    public func load() {
        viewModel.load()
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
        guard let group = viewModel.group(with: indexPath.row) else { return }
        delegate?.onWidgetGroupPresent(group, widget: self)
    }
}

extension UICollectionViewFlowLayout: SRStoryLayout {
    public func updateSpacing(_ spacing: CGFloat) {
        minimumLineSpacing = spacing
        minimumInteritemSpacing = spacing
    }
    
    public func updateItemSize(_ size: CGSize) {
        itemSize = size
    }
}
