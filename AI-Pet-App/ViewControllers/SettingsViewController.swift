//
//  SettingsViewController.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/2/23.
//

import Foundation
import UIKit
import Firebase
// MARK: - SettingsViewController
class SettingsViewController: UIViewController {
    // MARK: - Private API
    // Settings Labels
    lazy var settingsLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont(name: "AvenirNext-Bold", size: 24)
        label.textColor = Constants.textColor.hexToUiColor()
        label.textAlignment = .left
        label.frame = CGRect(x: 30, y: 100, width: 200, height: 30)

        return label
    }()
    lazy var accountIdLabel: UILabel = {
        let label = UILabel()
        let id = Auth.auth().currentUser?.uid ?? "No ID"
        label.text = "Support ID\n\(id)"
        label.font = UIFont(name: "AvenirNext-Bold", size: 14)
        label.textColor = Constants.textColor.hexToUiColor()
        label.textAlignment = .left
        label.numberOfLines = 0
        // set id text to be gray, "Account ID" to be text color
        let attributedString = NSMutableAttributedString(string: label.text ?? "")
        attributedString.addAttribute(.foregroundColor, value: Constants.textColor.hexToUiColor(), range: NSRange(location: 0, length: 10))
        attributedString.addAttribute(.foregroundColor, value: Constants.textColor.hexToUiColor().withAlphaComponent(0.5), range: NSRange(location: 11, length: id.count))
        label.attributedText = attributedString
        
        label.frame = CGRect(x: 30, y: 180, width: UIScreen.main.bounds.width - 60, height: 40)

        return label
    }()
    lazy var signedInInfoLabel: UILabel = {
        let label = UILabel()
        // check if we signed in, if we are, check if we are signed in anonymously
        if Auth.auth().currentUser != nil {
            if Auth.auth().currentUser?.isAnonymous == true {
                label.text = "You are currently signed in as a guest. Sign in with your phone to sync your data across devices."
                // orange or red color
                label.textColor = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
            } else {
                label.text = "You're signed in! Any orders you place and all images generated will be linked to your account."
                // pretty green color
                label.textColor = UIColor(red: 0, green: 0.8, blue: 0.2, alpha: 1)
            }
        } else {
            label.text = "Not signed in"
            // red
            label.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        }
        label.numberOfLines = 0
        label.font = UIFont(name: "AvenirNext-Bold", size: 14)
        label.textAlignment = .left
        label.frame = CGRect(x: 30, y: accountIdLabel.frame.maxY + 10, width: UIScreen.main.bounds.width - 60, height: 68)

        return label
    }()
    lazy var signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login  →", for: .normal)
        button.setTitleColor(Constants.textColor.hexToUiColor(), for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 14)
        if Auth.auth().currentUser != nil {
            if Auth.auth().currentUser?.isAnonymous == true {
                button.styleForNotLoggedIn()
            } else {
                button.styleForLogout()
            }
        } else {
            button.styleForNotLoggedIn()
        }
        
        button.frame = CGRect(x: 30, y: signedInInfoLabel.frame.maxY + 20, width: UIScreen.main.bounds.width - 60, height: 50)
        button.addTarget(self, action: #selector(signInButtonPressed), for: .touchUpInside)
        return button
    }()
    // notifications settings
    lazy var notificationsLabel: UILabel = {
        let label = UILabel()
        label.text = "Push Notifications"
        label.font = UIFont(name: "AvenirNext-Bold", size: 16)
        label.textColor = Constants.textColor.hexToUiColor()
        label.textAlignment = .left
        label.frame = CGRect(x: 30, y: signInButton.frame.maxY + 30, width: 200, height: 30)

        return label
    }()
    // notifications for order completion
    lazy var orderNotificationsLabel: UILabel = {
        let label = UILabel()
        label.text = "Orders"
        label.font = UIFont(name: "AvenirNext-Bold", size: 14)
        label.textColor = .gray
        label.textAlignment = .left
        label.frame = CGRect(x: 30, y: notificationsLabel.frame.maxY + 10, width: 200, height: 30)

        return label
    }()
    lazy var orderNotificationsSwitch: UISwitch = {
        let switchView = UISwitch()
        switchView.isOn = true
        switchView.onTintColor = Constants.primaryColor.hexToUiColor()
        switchView.frame = CGRect(x: UIScreen.main.bounds.width - 60, y: notificationsLabel.frame.maxY + 10, width: 50, height: 30)
        return switchView
    }()
    // notifications for limited time offers
    lazy var ltoNotificationsLabel: UILabel = {
        let label = UILabel()
        label.text = "Limited Time Offers"
        label.font = UIFont(name: "AvenirNext-Bold", size: 14)
        label.textColor = .gray
        label.textAlignment = .left
        label.frame = CGRect(x: 30, y: orderNotificationsLabel.frame.maxY + 15, width: 200, height: 30)

        return label
    }()
    lazy var ltoNotificationsSwitch: UISwitch = {
        let switchView = UISwitch()
        switchView.isOn = true
        switchView.onTintColor = Constants.primaryColor.hexToUiColor()
        switchView.frame = CGRect(x: UIScreen.main.bounds.width - 60, y: orderNotificationsLabel.frame.maxY + 15, width: 50, height: 30)
        switchView.center.y = ltoNotificationsLabel.center.y
        return switchView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backgroundColor.hexToUiColor()
        view.addSubview(settingsLabel)
        view.addSubview(accountIdLabel)
        view.addSubview(signedInInfoLabel)
        view.addSubview(signInButton)
        view.addSubview(notificationsLabel)
        view.addSubview(orderNotificationsLabel)
        view.addSubview(orderNotificationsSwitch)
        view.addSubview(ltoNotificationsLabel)
        view.addSubview(ltoNotificationsSwitch)
    }
    // sign in pressed
    @objc func signInButtonPressed() {
        if Auth.auth().currentUser != nil {
            if Auth.auth().currentUser?.isAnonymous == true {
                // sign in
                presentSignInVC()
            } else {
                // sign out
                do {
                    try Auth.auth().signOut()
                    // update UI
                    signedInInfoLabel.text = "You are currently signed in as a guest. Sign in with your phone to sync data across devices."
                    signedInInfoLabel.textColor = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
                    signInButton.styleForNotLoggedIn()
                } catch let error {
                    print("Error signing out: \(error)")
                }
            }
        } else {
            // sign in
            presentSignInVC()
        }
    }
    func presentSignInVC() {
        // vibration
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        let vc = SignInPopup()
        vc.parentVC = self
        Analytics.logEvent("sign_in_pressed", parameters: nil)
        self.presentPanModal(vc)
    }
    func updateUI() {
        // update UI to reflect sign in
        if Auth.auth().currentUser != nil {
            if Auth.auth().currentUser?.isAnonymous == true {
                // update UI
                signedInInfoLabel.text = "You are currently signed in as a guest. Sign in with your phone to sync data across devices."
                signedInInfoLabel.textColor = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
                signInButton.styleForNotLoggedIn()
            } else {
                // update UI
                signedInInfoLabel.text = "You're signed in! Any orders you place and all images generated will be linked to your account."
                // pretty green color
                signedInInfoLabel.textColor = UIColor(red: 0, green: 0.8, blue: 0.2, alpha: 1)
                signInButton.styleForLogout()
            }
        } else {
            // update UI
            signedInInfoLabel.text = "You are currently signed in as a guest. Sign in with your phone to sync data across devices."
            signedInInfoLabel.textColor = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1)
            signInButton.styleForNotLoggedIn()
        }

    }
}
extension UIButton {
    func styleForNotLoggedIn() {
        self.setTitle("Login  →", for: .normal)
        self.setTitleColor(Constants.textColor.hexToUiColor(), for: .normal)
        self.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 14)
        self.backgroundColor = Constants.surfaceColor.hexToUiColor()
        // add shadow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.2

        self.layer.cornerRadius = 10
    }
    func styleForLogout() {
        self.setTitle("Logout", for: .normal)
        self.setTitleColor(Constants.textColor.hexToUiColor(), for: .normal)
        self.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 14)
        self.backgroundColor = Constants.backgroundColor.hexToUiColor()
        // add shadow
        self.layer.borderColor = Constants.textColor.hexToUiColor().cgColor
        self.layer.borderWidth = 2


        self.layer.cornerRadius = 10
    }
}
