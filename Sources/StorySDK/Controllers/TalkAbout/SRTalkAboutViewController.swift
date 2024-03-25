//
//  SRTalkAboutViewController.swift
//  
//
//  Created by Aleksei Cherepanov on 27.06.2022.
//

#if os(macOS)
    import Cocoa

    final class SRTalkAboutViewController: NSViewController {
        
        init(story: SRStory, data: SRWidget, talkAboutWidget: SRTalkAboutWidget, loader: SRImageLoader, completion: @escaping (String?) -> Void) {
            super.init(nibName: nil, bundle: nil)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
#elseif os(iOS)
    import UIKit

    final class SRTalkAboutViewController: UIViewController, SRTalkAboutViewDelegate {
        let widget: SRTalkAboutView
        let background: UIVisualEffectView = .init(effect: UIBlurEffect(style: .light))
        private var keyboardHeight: CGFloat = 0
        private let completion: (String?) -> Void
        
        init(story: SRStory, defaultStorySize: CGSize, data: SRWidget, talkAboutWidget: SRTalkAboutWidget, loader: SRImageLoader, completion: @escaping (String?) -> Void) {
            self.widget = .init(
                story: story,
                defaultStorySize: defaultStorySize,
                data: data,
                talkAboutWidget: talkAboutWidget,
                loader: loader
            )
            self.completion = completion
            super.init(nibName: nil, bundle: nil)
            modalPresentationStyle = .custom
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func loadView() {
            super.loadView()
            view.backgroundColor = .clear
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            addNotifications()
            addSubviews()
            setupWidget()
            addEvents()
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            background.frame = view.bounds
            updateWidgetFrame()
        }
        
        private func addNotifications() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillShow(notification:)),
                name: UIResponder.keyboardWillShowNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillHide(notification:)),
                name: UIResponder.keyboardWillHideNotification,
                object: nil
            )
        }
        
        private func addSubviews() {
            [background, widget].forEach(view.addSubview)
        }
        
        private func setupWidget() {
            widget.transform = .identity
            widget.becomeFirstResponder()
            widget.talkAboutDelegate = self
        }
        
        private func addEvents() {
            background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
        }
        
        func updateWidgetFrame() {
            var frame = view.bounds
            frame.origin.y += view.safeAreaInsets.top
            frame.size.height -= keyboardHeight + view.safeAreaInsets.top
            var size = CGSize.zero//SRWidgetConstructor.calcWidgetPosition(widget.data, story: widget.story).size
            size.width *= view.bounds.width
            size.height *= view.bounds.width
            size = widget.sizeThatFits(size)
            widget.frame = .init(
                x: frame.minX + (frame.width - size.width) / 2,
                y: frame.minY + (frame.height - size.height) / 2,
                width: size.width,
                height: size.height
            )
        }
        
        @objc func close() {
            dismiss(animated: true) { [completion] in completion(nil) }
        }
        
        // MARK: - Keyboard events
        
        @objc func keyboardWillShow(notification: NSNotification) {
            guard let userInfo = notification.userInfo as? NSDictionary,
                  let keyboardFrame = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue
            else { return }
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            updateWidgetFrame()
        }
        
        @objc func keyboardWillHide(notification: NSNotification) {
            keyboardHeight = 0
            updateWidgetFrame()
        }
        
        // MARK: - SRTalkAboutViewDelegate
        
        func needHideKeyboard(_ widget: SRTalkAboutView) {
            close()
        }
        
        func didSentTextAbout(_ widget: SRTalkAboutView, text: String?) {
            dismiss(animated: true) { [completion] in completion(text) }
        }
    }
#endif
