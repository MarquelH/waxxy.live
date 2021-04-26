//
//  HostBrowseViewController.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 10/25/20.
//  Copyright © 2020 Marquel Hendricks. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class HostBrowseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var hostTableView: UITableView!
    @IBOutlet weak var loginToSubscribeButton: UIButton!
    @IBOutlet weak var exploreOrSubscribeSegment: UISegmentedControl!
    @IBOutlet weak var hostSearchBar: UISearchBar!
    let sb = UIStoryboard(name: "Main", bundle: nil)
    //TODO CHANGE THIS TO ARRAY OF HOST OBJECTS
    var hostArr = [NSDictionary]()
    var db: Firestore!
    var guestInfo = [String: Any?]()
    var djInfo = [String: Any?]()
    var host: Host?
    var listener: Listener?
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()

        // Do any additional setup after loading the view.
        hostTableView.isHidden = false
        loginToSubscribeButton.isHidden = true
        hostTableView.delegate = self
        hostTableView.dataSource = self
        hostSearchBar.delegate = self
        hostTableView.backgroundColor = UIColor.black
        loadUpHosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    func loadUpHosts() {
        let docRef = db.collection("hosts")
        //DispatchQueue.main.async {
            docRef.getDocuments { (querySnapshot, error) in
                if let err = error {
                    print("Error getting documents: \(err)")
                    //LOAD UP CACHED VERSION
                } else {
                    for document in querySnapshot!.documents {
                        /*guard let snap = document.data() else { }
                        let docId = document.documentID
                        let obj = snap[docId]
                        print(obj)*/
                        print("\(document.documentID) => \(document.data())")
                        let dict = document.data() as NSDictionary
                        if !self.hostArr.contains(dict) {
                            self.hostArr.append(dict)
                        }
                        //STORE A CACHED VERSION OF THIS LIST
                        //print(self.hostArr)
                    }
                }
                DispatchQueue.main.async {
                    self.hostTableView.reloadData()
                }
            }
            print("RELOADING DATA")
        //}
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.hostArr.removeAll()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    @IBAction func loginToSubscribePressed(_ sender: Any) {
        
    }
    
    @IBAction func exploreOrSubscribeSegmentChanged(_ sender: Any) {
        if exploreOrSubscribeSegment.selectedSegmentIndex == 0 {
            loginToSubscribeButton.isHidden = true
            hostTableView.isHidden = false
        } else {
            loginToSubscribeButton.isHidden = false
            hostTableView.isHidden = true
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(hostArr.count)
        return hostArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "djCell", for: indexPath)
        cell.backgroundColor = UIColor.black
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.text = self.hostArr[indexPath.row]["username"] as! String
        cell.detailTextLabel?.text = self.hostArr[indexPath.row]["region"] as! String
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profileViewController = sb.instantiateViewController(withIdentifier: "HostProfileViewController") as! HostProfileViewController
        if self.hostArr.count != 0 {
            let hostInfo = self.hostArr[indexPath.row]
            if let username = hostInfo["username"] as? String,
               let region = hostInfo["region"] as? String,
               let topGenres = hostInfo["topGenres"] as? String,
               let hostType = hostInfo["hostType"] as? String,
               let email = hostInfo["email"] as? String {
                //if let hostStreamInfo = hostInfo["streamInfo"]
                let host = Host(entity: Host.entity(), insertInto: self.context)
                host.username = username
                host.region = region
                let topGenresSplit = topGenres.components(separatedBy: ",")
                host.topGenres = topGenresSplit
                host.hostType = hostType
                host.email = email
                profileViewController.host = host
                self.present(profileViewController, animated: true)
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                //Some of the DJ info isn't there
            }
        }
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
