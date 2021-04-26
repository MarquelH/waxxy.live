//
//  HostProfileViewController.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 11/18/20.
//  Copyright © 2020 Marquel Hendricks. All rights reserved.
//

import UIKit
import AVKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class HostProfileViewController: UIViewController {
    @IBOutlet weak var hostImageView: UIImageView!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var topGenresLabel: UILabel!
    @IBOutlet weak var numberOfSubscribersLabel: UILabel!
    @IBOutlet weak var tempContentLabel: UILabel!
    @IBOutlet weak var avPlayerView: UIView!
    @IBOutlet weak var hostNameAndTypeLabel: UILabel!
    @IBOutlet weak var tuneInButton: UIButton!
    @IBOutlet weak var hostTypeLabel: UILabel!
    var djInfo: NSDictionary!
    var host: Host?
    var listener: Listener?
    var db: Firestore!
    var hostNameText: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO HANDLE WHEN THERE IS NO HOST
        regionLabel.text = host?.region
        //topGenresLabel.text = djInfo["topGenres"] as! String
        hostNameAndTypeLabel.text =  host?.username
        hostTypeLabel.text = host?.hostType
        numberOfSubscribersLabel.text = String(host!.numSubscribers)
        //PLAY STREAM (COUNTDOWN FOR NON-SUBS)
        // Do any additional setup after loading the view.
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        /*if djInfo["stream"] != nil {
            setUI(isStreaming: true)
        } else {
            setUI(isStreaming: false)
        }*/
        presentDJStream()
    }
    
    @IBAction func tuneInPressed(_ sender: Any) {
        if tuneInButton.titleLabel?.text == "Tune Out" {
            setUI(isStreaming: false)
        } else {
            presentDJStream()
        }
    }
    
    
    func presentDJStream() {
        if let streamInfo = host?.streamInfo {
            print(streamInfo)
            let playbackId = streamInfo["playbackId"] as! String
            let videoURL = URL(string: "https://stream.mux.com/\(playbackId).m3u8")
            let player = AVPlayer(url: videoURL!)
            let avPlayerViewController = AVPlayerViewController()
            avPlayerViewController.player = player
            avPlayerViewController.view.frame = self.avPlayerView.frame
            avPlayerViewController.showsPlaybackControls = true
            self.addChild(avPlayerViewController)
            self.view.addSubview(avPlayerViewController.view)
            avPlayerViewController.didMove(toParent: self)
            self.avPlayerView.isHidden = false
            self.tempContentLabel.isHidden = true
            self.tuneInButton.titleLabel?.text = "Tune Out"
            player.play()
        } else {
            self.avPlayerView.isHidden = true
            self.tempContentLabel.isHidden = false
            self.tuneInButton.isHidden = true
            print("STREAM INFO NOT PRESENT")
        }
    }
    
    func setUI(isStreaming: Bool) {
        self.avPlayerView.isHidden = true
        self.tempContentLabel.isHidden = false
        if isStreaming {
            self.tuneInButton.isHidden = false
        } else {
            self.tuneInButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func subscribePressed(_ sender: Any) {
        //TODO: CHECK DB FOR SUBSCRIBE VS THE ACTION
        let alert = UIAlertController(title: "Confirm Subscription", message: "Please choose your subscripton method for \(hostNameText!)", preferredStyle: UIAlertController.Style.alert)
        doAlertColoring(alertController: alert)
        
        let monthlyOption = UIAlertAction(title: NSLocalizedString("$3/Monthly", comment: "open"), style: .default) {
            (action: UIAlertAction) in
            print("OPEN UP $3 PAYMENT UI HERE")
        }
        
        let oneTimeOption = UIAlertAction(title: NSLocalizedString("$2/Current or Next Stream Only", comment: "open"), style: .default) {
            (action: UIAlertAction) in
            //Check for current show or for near future show
            print("OPEN UP $2 PAYMENT UI HERE")
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "cancel"), style: .destructive, handler: nil)
        alert.addAction(monthlyOption)
        alert.addAction(oneTimeOption)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func exitTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func doAlertColoring(alertController: UIAlertController) {
        /// Accessing alert view backgroundColor :
        alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = UIColor.darkGray
        // Accessing buttons tintcolor :
        alertController.view.tintColor = UIColor.white
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
