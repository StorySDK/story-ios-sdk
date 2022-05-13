//
//  SRStoryWidget.swift
//  
//
//  Created by Aleksei Cherepanov on 13.05.2022.
//

import UIKit

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
    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.minimumLineSpacing = 14
        l.itemSize = .init(width: 90, height: 90)
        return l
    }()
    private lazy var collectionView: UICollectionView = {
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.contentInset = .init(top: 14, left: 14, bottom: 14, right: 14)
        v.register(SRCollectionCell.self, forCellWithReuseIdentifier: "StoryCell")
        return v
    }()
    
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
        viewModel.onReloadData = { [weak collectionView] in
            collectionView?.reloadData()
        }
    }
    
    public func load(app: StoryApp) {
        viewModel.load(app: app)
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
