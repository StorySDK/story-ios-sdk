//
//  DemoTableViewCell.swift
//  ios-sdk-demo
//
//  Created by MeadowsPhone Team on 04.02.2022.
//

import UIKit
import ios_sdk

class DemoTableViewCell: UITableViewCell {
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var finishLabel: UILabel!
    
    private var isStarted = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func fillCell(_ group: StoryGroup, preferredLanguage: String, defaultLanguage: String) {
        roundedView.layer.cornerRadius = roundedView.frame.width / 2
        roundedView.layer.borderWidth = 2
        roundedView.layer.borderColor = group.active ? pinkColor.cgColor : UIColor.gray.cgColor
        imgView.layer.cornerRadius = imgView.frame.width / 2
        let imageLanguage = group.image_url.keys.contains(preferredLanguage) ? preferredLanguage : defaultLanguage
        if isStarted, let image_url = group.image_url[imageLanguage], let url = URL(string: image_url) {
            isStarted = false
            imgView.load(url: url)
        }
        let titleLanguage = group.title.keys.contains(preferredLanguage) ? preferredLanguage : defaultLanguage
        if let title = group.title[titleLanguage] {
            titleLabel.text = title
        }
        activeLabel.text = group.active ? "True" : "False"
        if !group.active {
            backgroundColor = .lightGray.withAlphaComponent(0.3)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if group.start_time != "" {
            let date = Date(timeIntervalSince1970: TimeInterval(group.start_time)! / 1000)
            startLabel.text = dateFormatter.string(from: date)
        }
        if group.end_time != "" {
            let date = Date(timeIntervalSince1970: TimeInterval(group.end_time)! / 1000)
            finishLabel.text = dateFormatter.string(from: date)
        }
    }
}
