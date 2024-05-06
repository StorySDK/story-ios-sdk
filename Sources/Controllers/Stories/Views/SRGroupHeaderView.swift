//
//  SRGroupHeaderView.swift
//  
//
//  Created by Aleksei Cherepanov on 09.06.2022.
//

#if os(macOS)
    import Cocoa

    class SRGroupHeaderView: StoryView {
        struct Size {
            static let image: CGFloat = 32
        }
        
        init() {
            super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 32))
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
#elseif os(iOS)
    import UIKit

    class SRGroupHeaderView: StoryView {
        struct Size {
            static let image: CGFloat = 32
        }
        
        var image: UIImage? {
            get { imageView.image }
            set { imageView.image = newValue }
        }
        var title: String? {
            get { titleLabel.text }
            set { titleLabel.text = newValue }
        }
        var duration: String? {
            get { durationLabel.text }
            set { durationLabel.text = newValue }
        }
        
        private let imageView: UIImageView = {
            let v = UIImageView(frame: .zero)
            v.contentMode = .scaleAspectFill
            v.layer.cornerRadius = Size.image / 2
            v.layer.masksToBounds = true
            return v
        }()
        
        private let titleLabel: UILabel = {
            let v = UILabel(frame: .zero)
            v.font = .medium(ofSize: 14)
            v.textColor = .white
            v.setContentHuggingPriority(.required, for: .horizontal)
            v.setContentCompressionResistancePriority(.required, for: .horizontal)
            return v
        }()
        
        private let durationLabel: UILabel = {
            let v = UILabel(frame: .zero)
            v.font = .regular(ofSize: 14)
            v.textColor = .white
            v.alpha = 0.5
            return v
        }()
        
        init() {
            // TODO: check sizes
            super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 32))
            setupLayout()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupLayout() {
            for v: UIView in [imageView, titleLabel, durationLabel] {
                v.translatesAutoresizingMaskIntoConstraints = false
                addSubview(v)
            }
            
            NSLayoutConstraint.activate([
                imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: Size.image),
                imageView.heightAnchor.constraint(equalToConstant: Size.image),
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                imageView.topAnchor.constraint(equalTo: topAnchor),
                
                titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
                
                durationLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                durationLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
                durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
        }
    }
#endif
