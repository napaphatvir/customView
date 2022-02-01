//
//  CurveTabBarController.swift
//  CurveTabBar
//
//  Created by Admin on 9/11/2564 BE.
//

import UIKit

final class CurveTabBarController: UITabBarController {
    override var selectedViewController: UIViewController? {
        willSet {
            guard let viewController = newValue,
                  let tabBar = tabBar as? CurveTabBar,
                  let index = viewControllers?.firstIndex(of: viewController) else { return }
            tabBar.selectedItem(at: index)
        }
    }
    
    override var selectedIndex: Int {
        willSet {
            guard let tabBar = tabBar as? CurveTabBar else { return }
            tabBar.selectedItem(at: newValue)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        if let tabBar = tabBar as? CurveTabBar {
            tabBar.animation = true
            tabBar.animateDuration = 0.3
        }
    }
}
