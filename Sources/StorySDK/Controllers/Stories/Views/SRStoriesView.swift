//
//  SRStoriesView.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

import UIKit

final class SRStoriesView: UIView {
    var delegate: UICollectionViewDelegate? {
        get { collectionView.delegate }
        set { collectionView.delegate = newValue }
    }
    var dataSource: UICollectionViewDataSource? {
        get { collectionView.dataSource }
        set { collectionView.dataSource = newValue }
    }
    var progress: Float {
        get { progressView.progress }
        set { progressView.progress = newValue }
    }
    
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let collectionView: UICollectionView = {
        let l = UICollectionViewFlowLayout()
        l.minimumInteritemSpacing = 0
        l.minimumLineSpacing = 0
        l.scrollDirection = .horizontal
        
        let v = UICollectionView(frame: .zero, collectionViewLayout: l)
        v.showsHorizontalScrollIndicator = false
        v.isPagingEnabled = true
        v.register(SRStoryCollectionCell.self, forCellWithReuseIdentifier: "StoryCell")
        v.backgroundColor = .clear
        return v
    }()
    private let closeButton: UIButton = {
        let bt: UIButton
        let icon = UIImage(systemName: "xmark")
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = icon
            bt = .init(configuration: config)
        } else {
            bt = .init(type: .system)
            bt.setImage(icon, for: .normal)
        }
        bt.tintColor = .white
        return bt
    }()
    let progressView = SRProgressView()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        addSubview(collectionView)
        for v: UIView in [progressView, closeButton] {
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
        }
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            progressView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24),
            progressView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            closeButton.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 72),
            closeButton.heightAnchor.constraint(equalToConstant: 72),
        ])
    }
    
    func startLoading() {
        guard loadingIndicator.superview == nil else { return }
        collectionView.isHidden = true
        addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    
    func stopLoading() {
        guard loadingIndicator.superview != nil else { return }
        collectionView.isHidden = false
        loadingIndicator.stopAnimating()
        loadingIndicator.removeFromSuperview()
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        loadingIndicator.center = center
    }
    
    func addCloseTarget(_ target: Any, selector: Selector) {
        closeButton.addTarget(target, action: selector, for: .touchUpInside)
    }
    
    func scroll(to x: CGFloat, animated: Bool) {
        collectionView.setContentOffset(.init(x: x, y: 0), animated: animated)
    }
}
