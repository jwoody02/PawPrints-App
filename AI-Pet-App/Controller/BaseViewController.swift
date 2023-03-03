//
//  BaseViewController.swift
//  PrinterestTabBar
//
//  Created by Christophe Hoste on 01.05.20.
//  Copyright © 2020 Christophe Hoste. All rights reserved.
//

import UIKit
import TransitionButton
class BaseViewController: UIViewController {

    func toogleTabbar(hide: Bool) {
        guard let tabBar = tabBarController as? Tabbarcontoller else { return }
        tabBar.toggle(hide: hide)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backgroundColor.hexToUiColor()
        if Constants.isDebugEnabled {
//            var window : UIWindow = UIApplication.shared.keyWindow!
//            window.showDebugMenu()
            self.view.debuggingStyle = true
        }
    }
}
