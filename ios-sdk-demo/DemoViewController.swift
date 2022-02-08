//
//  ViewController.swift
//  ios-sdk-demo
//
//  Created by MeadowsPhone Team on 08.02.2022.
//

import UIKit
import Foundation
import ios_sdk


class DemoViewController: UIViewController {
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var getGoupsButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activeSwitcher: UISwitch!
    @IBOutlet weak var blockView: UIView!
    @IBOutlet weak var fullScreenSwitcher: UISwitch!
    @IBOutlet weak var showTitleSwitcher: UISwitch!

    private let sdkId = "f4f64a87-9ee7-4f47-9444-92b97fe596ed"
    
    private var storySDK: StorySDK!
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
        
        idTextField.text = sdkId
        storySDK = StorySDK(sdkId, preferredLanguage: preferredStoryLanguage)

        storySDK.setProgressDuration(10)
        
        storySDK.changePrefferedLanguage("en")
        
        getAppID()
    }

    private func getAppID() {
        storySDK.getApps(completion: { error, app in
            DispatchQueue.main.async {
                self.blockView.isHidden = true
            }
            if let error = error {
                self.showMessage(error.localizedDescription)
                return
            }
            if let app = app {
                self.storyApp = app
                self.defaultStoryLanguage = self.storyApp!.localization.default_locale
                self.storySDK.setDefaultLanguage(self.defaultStoryLanguage)
                DispatchQueue.main.async {
                    self.getGoupsButton.isEnabled = true
                    self.activeSwitcher.isEnabled = true
                    self.fullScreenSwitcher.isEnabled = true
                    self.showTitleSwitcher.isEnabled = true
                }
            }
            else {
                self.showMessage("Unknow error")
            }
        })
    }
    
    @IBAction func getGroupsClicked(_ sender: Any) {
        blockView.isHidden = false
        storySDK.getGroups(appID: storyApp.id, statistic: true, completion: { error, result in
            DispatchQueue.main.async {
                self.blockView.isHidden = true
            }
            if let error = error {
                self.showMessage(error.localizedDescription)
                return
            }
            if let result = result {
                self.groups = result
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    @IBAction func switcherChanged(_ sender: UISwitch) {
        if sender.tag == 0 {
            storySDK.setFullScreen(sender.isOn)
        }
        else {
            storySDK.setTitleEnabled(sender.isOn)
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
        if group.active {
            blockView.isHidden = false
            storySDK.getStories(group, statistic: true, completion: { error, result in
                DispatchQueue.main.async { [self] in
                    self.blockView.isHidden = true
                    if let error = error {
                        self.showMessage(error.localizedDescription)
                        return
                    }
                    if let result = result {
                        if result.count > 0 {
                            let storyViewController = StoriesViewController(result, for: group, activeOnly: self.activeSwitcher.isOn)
                            self.present(storyViewController, animated: true, completion: nil)
                        }
                        else {
                            self.showMessage("No active stories!")
                        }
                    }
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
