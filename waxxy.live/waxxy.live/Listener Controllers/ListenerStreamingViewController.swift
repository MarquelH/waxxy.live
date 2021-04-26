//
//  ListenerStreamingViewController.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 12/10/20.
//  Copyright © 2020 Marquel Hendricks. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class ListenerStreamingViewController: UIViewController {
    var playerController = AVPlayerViewController()
    var player:AVPlayer?
    var db: Firestore!
    var playbackData = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Replace YOUR_PLAYBACK_ID with your asset's playback ID
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
    }
    
    @IBAction func playVideoPressed(_ sender: Any) {
        var playbackData =
        db.collection("hosts").document("user1").getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map { (dataMap) in
                }
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
        //if playbackData != "" {
            let url = URL(string: "google.com")
                    
            if let movieURL = url {
                self.player = AVPlayer(url: movieURL)
                self.playerController.player = self.player
            }
        //}
        //self.present(self.playerController, animated: true, completion: {
                    //self.playerController.player?.play()
                //})
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
