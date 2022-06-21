//
//  SRStoryCollectionView.swift
//  
//
//  Created by Aleksei Cherepanov on 21.06.2022.
//

import UIKit

final class SRStoryCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    let verticalPanGestureRecognizer = UIPanGestureRecognizer()
    
    init() {
        let l = UICollectionViewFlowLayout()
        l.minimumInteritemSpacing = 0
        l.minimumLineSpacing = 0
        l.scrollDirection = .horizontal
        
        super.init(frame: .zero, collectionViewLayout: l)
        setupView()
        setupGesture()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGesture() {
        addGestureRecognizer(verticalPanGestureRecognizer)
        verticalPanGestureRecognizer.delegate = self
        verticalPanGestureRecognizer.addTarget(self, action: #selector(gestureUpdate))
    }
    
    private func setupView() {
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        register(SRStoryCollectionCell.self, forCellWithReuseIdentifier: "StoryCell")
        backgroundColor = .clear
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == verticalPanGestureRecognizer else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
        let velocity = verticalPanGestureRecognizer.velocity(in: self)
        return abs(velocity.y) > abs(velocity.x)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func gestureUpdate(_ gestureRecognizer: UIGestureRecognizer) {
        isScrollEnabled = gestureRecognizer.state.rawValue >= UIGestureRecognizer.State.ended.rawValue
    }
}
