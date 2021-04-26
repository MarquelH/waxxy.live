//
//  ListenersTabBarController.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 1/10/21.
//  Copyright © 2021 Marquel Hendricks. All rights reserved.
//

import UIKit

class ListenersTabBarController: UITabBarController {

    var guestInfo = [String: Any?]()
    var listener: Listener?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var homeTab = self.viewControllers![0] as! HomeViewController
        var browseTab = self.viewControllers![1] as! HostBrowseViewController
        var settingsTab = self.viewControllers![2] as! ListenerSettingsViewController
        
        homeTab.guestInfo = self.guestInfo
        homeTab.listener = self.listener
        
        browseTab.guestInfo = self.guestInfo
        browseTab.listener = self.listener
        
        settingsTab.guestInfo = self.guestInfo
        settingsTab.listener = self.listener
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
