//
//  SRStoriesView.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

#if os(macOS)
    import Cocoa

    final class SRStoriesView: StoryView {
        init() {
            super.init(frame: .zero)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
#elseif os(iOS)
    import UIKit

    final class SRStoriesView: StoryView {
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
            set {
                progressView.progress = newValue
            }
        }
        var groupImage: UIImage? {
            get { headerView.image }
            set { headerView.image = newValue }
        }
        var groupName: String? {
            get { headerView.title }
            set { headerView.title = newValue }
        }
        var groupDuration: String? {
            get { headerView.duration }
            set { headerView.duration = newValue }
        }
        var isHeaderHidden: Bool {
            get { headerView.isHidden }
            set {
                headerView.isHidden = newValue
                headerGradientView.isHidden = newValue
            }
        }
        var isScrollEnabled: Bool {
            get { collectionView.isScrollEnabled }
            set { collectionView.isScrollEnabled = newValue }
        }
        var isItChildViewController: Bool = false
        var isFilled: Bool = false
        var isProhibitToClose: Bool = false {
            didSet {
                closeButton.isHidden = isProhibitToClose
            }
        }
        
        var isProgressHidden: Bool = false {
            didSet {
                progressView.isHidden = isProgressHidden
            }
        }
        
        let collectionView: UICollectionView = {
            let l = UICollectionViewFlowLayout()
            l.minimumInteritemSpacing = 0
            l.minimumLineSpacing = 0
            l.scrollDirection = .horizontal
            let v = UICollectionView(frame: .zero, collectionViewLayout: l)
            v.showsHorizontalScrollIndicator = false
            v.isPagingEnabled = true
            v.register(SRStoryCollectionCell.self, forCellWithReuseIdentifier: "StoryCell")
            v.backgroundColor = .clear
            v.contentInsetAdjustmentBehavior = .never
            return v
        }()
        
        private let loadingIndicator: SRLoader = {
            let indicator = StorySDK.shared.configuration.loader
            return indicator
        }()
        
        private let closeButton: UIButton = {
            let bt: UIButton
            let icon = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18))
            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.plain()
                config.image = icon
                config.contentInsets = .init(top: 15, leading: 15, bottom: 15, trailing: 12)
                bt = .init(configuration: config)
            } else {
                bt = .init(type: .system)
                bt.setImage(icon, for: .normal)
                bt.contentEdgeInsets = .init(top: 15, left: 15, bottom: 15, right: 12)
            }
            bt.tintColor = .white
            return bt
        }()
        private let contentView: UIView = {
            let v = UIView(frame: StoryScreen.screenBounds)
            v.layer.cornerRadius = 0
            v.layer.masksToBounds = true
            return v
        }()
        private let headerView = SRGroupHeaderView()
        private let headerGradientView: CAGradientLayer = {
            let l = CAGradientLayer()
            l.startPoint = CGPoint(x: 0.5, y: 0.0)
            l.endPoint = CGPoint(x: 0.5, y: 1.0)
            l.colors = [
                UIColor.black.withAlphaComponent(0.2),
                UIColor.clear
            ].map(\.cgColor)
            return l
        }()
        public let progressView = SRProgressView()
        
        init(defaultStorySize: CGSize) {
            super.init(frame: .zero)
            setupView()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupView() {
            backgroundColor = .systemBackground
            [contentView].forEach(addSubview)
            [collectionView].forEach(contentView.addSubview)
            contentView.layer.addSublayer(headerGradientView)
            [progressView, headerView, closeButton].forEach(contentView.addSubview)
            [progressView, headerView, closeButton].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
            
            NSLayoutConstraint.activate([
                progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
                progressView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
                progressView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                
                headerView.leadingAnchor.constraint(equalTo: progressView.leadingAnchor),
                headerView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
                headerView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor),
                
                closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                closeButton.topAnchor.constraint(equalTo: progressView.bottomAnchor),
                closeButton.widthAnchor.constraint(equalToConstant: 48),
                closeButton.heightAnchor.constraint(equalToConstant: 48),
            ])
        }
        
        func startLoading() {
            collectionView.isHidden = true
            
            guard loadingIndicator.superview == nil else { return }
            addSubview(loadingIndicator)
            loadingIndicator.startAnimating()
        }
        
        func stopLoading() {
            collectionView.isHidden = false
            
            guard loadingIndicator.superview != nil else { return }
            loadingIndicator.stopAnimating()
            loadingIndicator.removeFromSuperview()
        }
        
        func reloadData() {
            collectionView.reloadData()
        }
        
        override func layoutSubviews() {
            if isItChildViewController {
                contentView.frame = bounds
            } else {
                if isFilled {
                    contentView.frame = bounds
                } else {
                    contentView.frame = .init(
                        x: 0,
                        y: 0,
                        width: bounds.width,
                        height: bounds.height
                    )
                }
            }
            super.layoutSubviews()
            headerGradientView.frame = .init(
                x: 0,
                y: 0,
                width: contentView.frame.width,
                height: closeButton.frame.maxY + closeButton.frame.height
            )
            
            collectionView.frame = contentView.bounds
            loadingIndicator.center = center
        }
        
        func addCloseTarget(_ target: Any, selector: Selector) {
            closeButton.addTarget(target, action: selector, for: .touchUpInside)
        }
        
        func scroll(to x: CGFloat, animated: Bool) {
            collectionView.setContentOffset(.init(x: x, y: 0), animated: animated)
        }
    }
#endif
