//
//  ViewController.swift
//  ios-sdk-demo
//
//  Created by MeadowsPhone Team on 08.02.2022.
//

import UIKit
import Foundation
import StorySDK

class DemoViewController: UIViewController {
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var getGoupsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activeSwitcher: UISwitch!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var fullScreenSwitcher: UISwitch!
    @IBOutlet weak var showTitleSwitcher: UISwitch!

    private let storySDK = StorySDK(
        configuration: .init(
            language: "en",
            sdkId: "f4f64a87-9ee7-4f47-9444-92b97fe596ed",
            storyDuration: 10
        )
    )
    private var groups = [StoryGroup]()
    private var storyApp: StoryApp!
    
    private var defaultStoryLanguage = "en"
    private var preferredStoryLanguage = String(Locale.preferredLanguages[0].prefix(2))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        blockView.isHidden = false
        activeSwitcher.isOn = false
        showTitleSwitcher.isOn = false
        getGoupsButton.isEnabled = false
        activeSwitcher.isEnabled = false
        fullScreenSwitcher.isEnabled = false
        showTitleSwitcher.isEnabled = false
        
        getAppID()
    }

    private func getAppID() {
        storySDK.getApps { [weak self] result in
            DispatchQueue.main.async { self?.blockView.isHidden = true }
            guard let wSelf = self else { return }
            switch result {
            case .success(let apps):
                guard let app = apps.first else {
                    wSelf.showMessage("No stories to display")
                    return
                }
                wSelf.storyApp = app
                wSelf.defaultStoryLanguage = app.localization.defaultLocale
                wSelf.storySDK.configuration.language = wSelf.defaultStoryLanguage
                DispatchQueue.main.async {
                    wSelf.getGoupsButton.isEnabled = true
                    wSelf.activeSwitcher.isEnabled = true
                    wSelf.fullScreenSwitcher.isEnabled = true
                    wSelf.showTitleSwitcher.isEnabled = true
                }
            case .failure(let error):
                wSelf.showMessage(error.localizedDescription)
            }
        }
    }
    
    @IBAction func getGroupsClicked(_ sender: Any) {
        blockView.isHidden = false
        storySDK.getGroups(appId: storyApp.id, statistic: true) { [weak self] result in
            DispatchQueue.main.async { self?.blockView.isHidden = true }
            switch result {
            case .success(let groups):
                self?.groups = groups
                DispatchQueue.main.async { self?.tableView.reloadData() }
            case .failure(let error):
                self?.showMessage(error.localizedDescription)
            }
        }
    }
    
    @IBAction func switcherChanged(_ sender: UISwitch) {
        switch sender.tag {
        case 0: storySDK.configuration.needFullScreen = sender.isOn
        default: storySDK.configuration.needShowTitle = sender.isOn
        }
    }
    
    private func showMessage(_ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "warning",
                                          message: message,
                                          preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            })
            alert.addAction(ok)

            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension DemoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "demoTableViewCell") as? DemoTableViewCell {
            cell.fillCell(groups[indexPath.row], preferredLanguage: preferredStoryLanguage, defaultLanguage: defaultStoryLanguage)
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let group = groups[indexPath.row]
        guard group.active else { return }
        blockView.isHidden = false
        storySDK.getStories(group, statistic: true) { [weak self] result in
            DispatchQueue.main.async {
                self?.blockView.isHidden = true
                switch result {
                case .failure(let error):
                    self?.showMessage(error.localizedDescription)
                case .success(let stories):
                    if stories.isEmpty {
                        self?.showMessage("No active stories!")
                    } else {
                        self?.presentStories(stories, of: group)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func presentStories(_ stories: [Story], of group: StoryGroup) {
        let storyViewController = StoriesViewController(stories, for: group, activeOnly: activeSwitcher.isOn, sdk: storySDK)
        present(storyViewController, animated: true, completion: nil)
    }
}
