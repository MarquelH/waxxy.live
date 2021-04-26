//
//  MainTabBarController.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 9/26/20.
//  Copyright © 2020 Marquel Hendricks. All rights reserved.
//

import Foundation
import UIKit
import BATabBarController

class MainListenerTabBarController: UIViewController, BATabBarControllerDelegate {
    
    let sb = UIStoryboard(name: "Main", bundle: nil)
    
    func tabBarController(_ tabBarController: BATabBarController, didSelect: UIViewController) {
        
    }
    
    override func viewDidLoad() {
        setupTabBar()
    }
    
    func setupTabBar() {
        let baTabBarController = generateBATabBarController(isDJView: false, restorationId: "baTabBar")
        self.view.addSubview(baTabBarController.view)
    }
    
    func setupDJProfileVC() {
        let baTabBarController = generateBATabBarController(isDJView: true, restorationId: "baTabBar2")

        print("SETTING UP")
        for view in self.view.subviews {
            if view.restorationIdentifier == "baTabBar" {
                view.removeFromSuperview()
            }
        }
        self.view.addSubview(baTabBarController.view)
    }
    
    func generateBATabBarController(isDJView: Bool, restorationId: String) -> BATabBarController {
        let baTabBarController = BATabBarController()
        let vc = UIViewController()
        
        let homeViewController = sb.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        let loginViewController = sb.instantiateViewController(withIdentifier: "LoginViewController") as!
            LoginViewController
        let hostBrowseViewController = sb.instantiateViewController(identifier: "HostBrowseViewController") as! HostBrowseViewController
        let hostStreamingViewController = sb.instantiateViewController(identifier: "HostStreamingViewController") as! HostStreamingViewController
        let profileViewController = sb.instantiateViewController(withIdentifier: "HostProfileViewController") as! HostProfileViewController
        
        let homeText = NSMutableAttributedString(string: "Home")
        let homeTab  = BATabBarItem(image: UIImage(named: "house-128")!, selectedImage: UIImage(named: "house-128")!, title: homeText)
        
        let profileText = NSMutableAttributedString(string: "Profile")
        let profileTab = BATabBarItem(image: UIImage(named: "user-128")!, selectedImage: UIImage(named: "user-128")!, title: profileText)
        
        let settingsText = NSMutableAttributedString(string: "Settings")
        let settingsTab = BATabBarItem(image: UIImage(named: "settings-9-128")!, selectedImage: UIImage(named: "settings-9-128")!, title: settingsText)
        
        let hostBrowseText = NSMutableAttributedString(string: "Host Browse")
        let hostBrowseTab = BATabBarItem(image: UIImage(named: "dj-128")!, selectedImage: UIImage(named: "dj-128")!, title: hostBrowseText)
        
        let hostStreamingText = NSMutableAttributedString(string: "Streaming")
        let hostStreamTab = BATabBarItem(image: UIImage(named: "video-play-2-128")!, selectedImage: UIImage(named: "video-play-2-128")!, title: hostStreamingText)
        
        baTabBarController.tabBarBackgroundColor = UIColor.black
        baTabBarController.tabBarItemStrokeColor = UIColor.systemBlue
        if isDJView {
            baTabBarController.viewControllers = [homeViewController, hostBrowseViewController, hostStreamingViewController, profileViewController, vc]
        } else {
            baTabBarController.viewControllers = [homeViewController, hostBrowseViewController, hostStreamingViewController, loginViewController, vc]
        }
        baTabBarController.tabBarItems = [homeTab, hostBrowseTab, hostStreamTab, profileTab, settingsTab]
        baTabBarController.delegate = self
        baTabBarController.restorationIdentifier = "baTabBar"
        baTabBarController.initialViewController = homeViewController
        return baTabBarController
    }
}
