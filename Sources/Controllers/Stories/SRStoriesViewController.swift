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
        
        public init(_ group: SRStoryGroup,
                    sdk: StorySDK = .shared,
                    delegate: SRStoryWidgetDelegate? = nil,
                    asOnboarding: Bool = false,
                    backgroundColor: UIColor = UIColor.black ) {
            self.group = group
            let dataStorage = SRDefaultStoriesDataStorage(sdk: sdk)
            let progressController = SRDefaultProgressController()
            let widgetResponder = SRDefaultWidgetResponder(sdk: sdk)
            let analyticsController = SRDefaultAnalyticsController(sdk: sdk)
            self.asOnboarding = asOnboarding
            self.delegate = delegate
            
            self.viewModel = .init(
                dataStorage: dataStorage,
                progress: progressController,
                widgetResponder: widgetResponder,
                analytics: analyticsController
            )
            
            super.init(nibName: nil, bundle: nil)
            
            
            view.backgroundColor = backgroundColor
            modalPresentationStyle = .overFullScreen
            isModalInPresentation = true
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public override func loadView() {
            super.loadView()
            let sz = groupSize()
            
            storiesView = .init(defaultStorySize: sz)
            view = storiesView
        }
        
        public func groupSize() -> CGSize {
            let sizePreset = group.settings?.sizePreset ?? .IphoneSmall
            let sz: CGSize
            switch sizePreset {
            case .IphoneSmall:
                sz = CGSize.smallStory
            case .IphoneLarge:
                sz = CGSize.largeStory
            }
            
            return sz
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
            storiesView.addShareTarget(self, selector: #selector(share))
            viewModel.onReloadData = { [weak self] in
                guard let wSelf = self else { return }
                
                wSelf.storiesView.reloadData()
                wSelf.viewModel.setupProgress(wSelf.storiesView.progressView)
                if !wSelf.storiesView.isProgressHidden {
                    wSelf.viewModel.startAutoscrolling()
                }
                
                wSelf.viewModel.onStoriesLoaded?()
                wSelf.storiesView.stopLoading()
                wSelf.viewModel.reportGroupOpen()
            }
            viewModel.onGotEmptyGroup = { [weak self] in
                logger.warning("group is empty")
                self?.notifyClose()
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
            viewModel.onStoriesLoading = { [weak self] in
                self?.delegate?.onWidgetLoading()
            }
            viewModel.onStoriesLoaded = { [weak self] in
                self?.delegate?.onWidgetLoaded()
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
            viewModel.onStoriesLoading?()
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
            
            notifyClose()
        }
        
        @objc func share() {
            guard let storyId = viewModel.dataStorage.analytics?.getCurrentShortStoryId() else { return }
            guard let url = URL(string: "https://app.storysdk.com/share/\(storyId)") else { return }
            
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            present(vc, animated: true, completion: nil)
        }
        
        @objc func notifyClose() {
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
            guard let cell = reusable as? SRStoryCollectionCell else {
                return reusable
            }
            
            viewModel.setupCell(cell, index: indexPath.row)
            cell.layoutCanvas()
            
            return cell
        }
        
        public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard let cell = cell as? SRStoryCollectionCell else { return }
            
            cell.startActivitiesIfNeeded()
            viewModel.willDisplay(cell, index: indexPath.row)
        }
        
        public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard let cell = cell as? SRStoryCollectionCell else { return }
            
            cell.cancelActivities()
            viewModel.endDisplaying(cell, index: indexPath.row)
        }
    }

    extension SRStoriesViewController: UICollectionViewDelegateFlowLayout {
        public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            collectionView.frame.size
        }
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) { }
        
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
