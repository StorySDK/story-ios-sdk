//
//  SRStoriesViewController.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

#if os(macOS)
    import Cocoa

    public final class SRStoriesViewController: StoryViewController {
        
        public init(_ group: SRStoryGroup, sdk: StorySDK = .shared) {
            super.init(nibName: nil, bundle: nil)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
#elseif os(iOS)
    import UIKit

    public final class SRStoriesViewController: StoryViewController {
        private var group: SRStoryGroup
        
        private let viewModel: SRStoriesViewModel
        private var storiesView: SRStoriesView!
        private let logger: SRLogger
        
        public weak var delegate: SRStoryWidgetDelegate?
        
        let tapGesture: UITapGestureRecognizer = {
            let gesture = UITapGestureRecognizer()
            gesture.isEnabled = true
            return gesture
        }()
        
        var isScrollEnabled: Bool {
            get { storiesView.isScrollEnabled }
            set {
                storiesView.isScrollEnabled = newValue
                tapGesture.isEnabled = !newValue
            }
        }
        
        var asOnboarding: Bool = false
        
        public init(_ group: SRStoryGroup, sdk: StorySDK = .shared, asOnboarding: Bool = false) {
            self.group = group
            self.logger = sdk.logger
            let dataStorage = SRDefaultStoriesDataStorage(sdk: sdk)
            let progressController = SRDefaultProgressController()
            let widgetResponder = SRDefaultWidgetResponder(sdk: sdk)
            let analyticsController = SRDefaultAnalyticsController(sdk: sdk)
            self.asOnboarding = asOnboarding
            
            self.viewModel = .init(
                dataStorage: dataStorage,
                progress: progressController,
                widgetResponder: widgetResponder,
                analytics: analyticsController
            )
            super.init(nibName: nil, bundle: nil)
            modalPresentationStyle = .overFullScreen
            isModalInPresentation = true
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func loadView() {
            super.loadView()
            storiesView = .init()
            view = storiesView
        }
        
        public override func viewDidLoad() {
            super.viewDidLoad()
            bindView()
            loadData(asOnboarding)
        }
        
        private func bindView() {
            storiesView.delegate = self
            storiesView.dataSource = self
            storiesView.addCloseTarget(self, selector: #selector(close))
            viewModel.onReloadData = { [weak self] in
                guard let wSelf = self else { return }
                
                wSelf.storiesView.reloadData()
                wSelf.viewModel.setupProgress(wSelf.storiesView.progressView)
                if !wSelf.storiesView.isProgressHidden {
                    wSelf.viewModel.startAutoscrolling()
                }
                
                wSelf.storiesView.stopLoading()
                wSelf.viewModel.reportGroupOpen()
            }
            viewModel.onGotEmptyGroup = { [weak self] in
                print("StorySDK > Warning: group is empty")
                self?.close()
            }
            viewModel.onErrorReceived = { [logger] error in
                logger.error(error.getDetails(), logger: .stories)
            }
            viewModel.presentTalkAbout = { [weak self] vc in
                self?.present(vc, animated: true)
            }
            viewModel.onProgressUpdated = { [weak self] progress in
                self?.storiesView.progress = progress
            }
            viewModel.onUpdateHeader = { [weak storiesView] info in
                storiesView?.progressView.setupInLoadingState(info: info)
                storiesView?.groupName = info.title
                storiesView?.groupDuration = info.duration
                storiesView?.groupImage = info.icon
                storiesView?.isHeaderHidden = info.isProgressHidden || info.isProhibitToClose
                storiesView?.isProhibitToClose = info.isProhibitToClose
                storiesView?.isProgressHidden = info.isProgressHidden
            }
            viewModel.onFilled = { [weak storiesView] value in
                //self?.close()
                storiesView?.isFilled = value
                storiesView?.layoutSubviews()
            }
            viewModel.onScrollToStory = { [weak storiesView] index, animated in
                guard let v = storiesView else { return }
                var x = v.frame.width * CGFloat(index)
                x = min(x, v.collectionView.contentSize.width - v.frame.width)
                x = max(x, 0)
                v.endEditing(true)
                v.scroll(to: x, animated: animated)
            }
            viewModel.onScrollCompleted = { [weak self] in
                self?.close()
            }
            viewModel.resignFirstResponder = { [weak self] in
                self?.view.endEditing(true)
            }
            viewModel.onMethodCall = { [weak self] selectorName in
                self?.delegate?.onWidgetMethodCall(selectorName)
            }
            viewModel.onStoriesClosed = { [weak self] in
                self?.delegate?.onWidgetGroupClose()
            }
            
            if group.type != .onboarding {
                tapGesture.addTarget(
                    viewModel.gestureRecognizer,
                    action: #selector(SRStoriesGestureRecognizer.onTap)
                )
                storiesView.addGestureRecognizer(tapGesture)
            }
        }
        
        private func loadData(_ asOnboading: Bool = false) {
            storiesView.startLoading()
            viewModel.loadStories(group: group, asOnboading: asOnboading)
        }
        
        public override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            viewModel.containerFrame = view.convert(view.bounds, to: nil)
        }
        
        public override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            storiesView.isItChildViewController = parent != nil
        }
        
        func willBeginTransition() {
            viewModel.willBeginTransition()
        }
        
        func didEndTransition() {
            guard view.window != nil else { return }
            viewModel.didEndTransition()
        }
        
        func updateOnScrollCompleted(_ completion: @escaping () -> Void) {
            viewModel.onScrollCompleted = completion
        }
        
        func updateOnGotEmptyGroup(_ completion: @escaping () -> Void) {
            viewModel.onGotEmptyGroup = completion
        }
        
        @objc func close() {
            if let groupSettings = group.settings {
                if groupSettings.isProhibitToClose {
                    return
                }
            }
            
            viewModel.reportGroupClose()
            dismiss(animated: true)
            
            viewModel.onStoriesClosed?()
        }
        
        // MARK: - Analytics gateway
        
        func reportSwipeForward() {
            viewModel.reportSwipeBackward()
        }
        
        func reportSwipeBackward() {
            viewModel.reportSwipeForward()
        }
    }

    extension SRStoriesViewController: UICollectionViewDataSource {
        public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            viewModel.numberOfItems
        }
        
        public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let reusable = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath)
            guard let cell = reusable as? SRStoryCollectionCell else { return reusable }
            viewModel.setupCell(cell, index: indexPath.row)
            cell.layoutCanvas()
            
            return cell
        }
        
        public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard let cell = cell as? SRStoryCollectionCell else { return }
            viewModel.willDisplay(cell, index: indexPath.row)
        }
        
        public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard let cell = cell as? SRStoryCollectionCell else { return }
            viewModel.endDisplaying(cell, index: indexPath.row)
        }
    }

    extension SRStoriesViewController: UICollectionViewDelegateFlowLayout {
        public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            collectionView.frame.size
        }
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            viewModel.didScroll(
                offset: Float(scrollView.contentOffset.x),
                contentWidth: Float(scrollView.contentSize.width)
            )
        }
        
        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            viewModel.willBeginDragging()
        }
        
        public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            viewModel.didScroll(
                offset: Float(scrollView.contentOffset.x),
                contentWidth: Float(scrollView.contentSize.width)
            )
            viewModel.didEndDragging()
        }
    }

    private extension Error {
        func getDetails() -> String {
            guard let error = self as? DecodingError else {
                return localizedDescription
            }
            switch error {
            case .typeMismatch(let key, let value):
                return "typeMismatch \(key), value \(value)"
            case .valueNotFound(let key, let value):
                return "valueNotFound \(key), value \(value)"
            case .keyNotFound(let key, let value):
                return "keyNotFound \(key), value \(value)"
            case .dataCorrupted(let key):
                return "dataCorrupted \(key)"
            default:
                return localizedDescription
            }
        }
    }
#endif
