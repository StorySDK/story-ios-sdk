//
//  SRStoriesViewController.swift
//  
//
//  Created by Aleksei Cherepanov on 19.05.2022.
//

import UIKit

public final class SRStoriesViewController: UIViewController {
    private let group: StoryGroup
    private let viewModel: SRStoriesViewModel
    private var storiesView: SRStoriesView!
    
    public init(_ group: StoryGroup, sdk: StorySDK = .shared) {
        self.group = group
        let dataStorage = SRDefaultStoriesDataStorage(sdk: sdk)
        let progressController = SRDefaultProgressController()
        let widgetResponder = SRDefaultWidgetResponder(sdk: sdk)
        let analyticsController = SRDefaultAnalyticsController(sdk: sdk)
        self.viewModel = .init(
            dataStorage: dataStorage,
            progress: progressController,
            widgetResponder: widgetResponder,
            analytics: analyticsController
        )
        super.init(nibName: nil, bundle: nil)
        if dataStorage.configuration.needFullScreen {
            modalPresentationStyle = .fullScreen
        }
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
        loadData()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.pauseAutoscrolling()
        viewModel.reportGroupClose()
    }
    
    private func bindView() {
        storiesView.delegate = self
        storiesView.dataSource = self
        storiesView.addCloseTarget(self, selector: #selector(close))
        viewModel.onReloadData = { [weak storiesView, weak viewModel] in
            storiesView?.stopLoading()
            storiesView?.reloadData()
            storiesView.map { viewModel?.setupProgress($0.progressView) }
            viewModel?.startAutoscrolling()
            viewModel?.reportGroupOpen()
        }
        viewModel.onErrorReceived = { error in
            logError(error.getDetails(), logger: .stories)
        }
        viewModel.onUpdateTransformNeeded = { [weak storiesView] ty in
            UIView.animate(
                withDuration: .animationsDuration,
                animations: { storiesView?.transform.ty = CGFloat(ty) }
            )
        }
        viewModel.onProgressUpdated = { [weak self] progress in
            self?.storiesView.progress = progress
        }
        viewModel.onScrollToStory = { [weak storiesView] index in
            guard let v = storiesView else { return }
            let x = v.frame.width * CGFloat(index)
            v.scroll(to: x, animated: true)
        }
        viewModel.onScrollCompeted = { [weak self] in
            self?.close()
        }
    }
    
    private func loadData() {
        storiesView.startLoading()
        viewModel.loadStories(group: group)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.containerFrame = view.convert(view.bounds, to: nil)
    }
    
    @objc func close() {
        dismiss(animated: true)
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
