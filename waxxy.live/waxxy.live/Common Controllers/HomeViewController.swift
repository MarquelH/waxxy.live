//
//  HomeViewController.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 9/27/20.
//  Copyright © 2020 Marquel Hendricks. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var djInfo = [String: Any?]()
    var guestInfo = [String: Any?]()
    var host: Host?
    var listener: Listener?
    var isHost: Bool?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { 
        guard let tableViewCell = cell as? HomeTableViewCell else { return }
        //tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
    }
    
    //let model: [[UIColor]] = generateRandomData()

    override func viewDidLoad() {
        super.viewDidLoad()
        isHost = isHost(hostPassed: host, listenerPassed: listener)
        // Do any additional setup after loading the view.
    }
    
    func isHost(hostPassed: Host?, listenerPassed: Listener?) -> Bool {
        if (hostPassed != nil) {
            return true
        }
        if (listenerPassed != nil) {
            return false
        }
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
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
