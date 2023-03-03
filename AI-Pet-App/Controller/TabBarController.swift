//
//  TabBarController.swift
//  PrinterestTabBar
//
//  Created by Christophe Hoste on 29.03.20.
//  Copyright © 2020 Christophe Hoste. All rights reserved.
//
// swiftlint:disable all
import UIKit

class Tabbarcontoller: UITabBarController {

    let floatingTabbarView = FloatingBarView(["small_paw.png", "magnifyingglass", "tray", "gearshape"])

    override func viewDidLoad() {
        super.viewDidLoad()
        // check if device is dark mode
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                floatingTabbarView.backgroundColor = .black
                // set new constants
                Constants.shared.setDarkModeConstants()
            } else {
                floatingTabbarView.backgroundColor = .white
            }
        } else {
            floatingTabbarView.backgroundColor = .white
        }
        viewControllers = [
            createNavViewController(viewController: ViewController(showPushButton: true), title: "Packs", imageName: "house.fill"),
            createNavViewController(viewController: SearchViewController(), title: "Search", imageName: "bubble.middle.bottom.fill"),
            createNavViewController(viewController: OrdersViewController(), title: "Orders", imageName: "flame.fill"),
            createNavViewController(viewController: SettingsViewController(), title: "Settings", imageName: "rectangle.3.offgrid.fill")
        ]
        tabBar.isHidden = true

        setupFloatingTabBar()
    }
    func changeTab(index: Int) {
        floatingTabbarView.changeTab(floatingTabbarView.buttons[index])
    }
    private func createNavViewController(viewController: UIViewController, title: String, imageName: String) -> UIViewController {

//        viewController.navigationItem.title = title
//        viewController.navigationItem.hidesBackButton = true

        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBar.prefersLargeTitles = true
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(systemName: imageName)

        return navController
    }

    func setupFloatingTabBar() {
        floatingTabbarView.delegate = self
        view.addSubview(floatingTabbarView)
        floatingTabbarView.centerXInSuperview()
        floatingTabbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
    }
    
    func toggle(hide: Bool) {
        floatingTabbarView.toggle(hide: hide)
    }
}

extension Tabbarcontoller: FloatingBarViewDelegate {
    func did(selectindex: Int) {
        selectedIndex = selectindex
        // have a slight vibration when tab is selected
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
