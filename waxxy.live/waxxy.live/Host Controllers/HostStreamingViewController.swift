//
//  HostStreamingViewController.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 11/6/20.
//  Copyright © 2020 Marquel Hendricks. All rights reserved.
//

import UIKit
import RPCircularProgress
import Hue
import Alamofire
import FirebaseFirestore
import FirebaseFirestoreSwift

class HostStreamingViewController: UIViewController {

    // MARK: - properties
    var db: Firestore!
    var djInfo = [String: Any?]()
    var host: Host?
    
    @IBAction func startStreamPressed(_ sender: Any) {
        setupBroadcastVC()
    }
    
    @IBAction func scheduleStreamPressed(_ sender: Any) {
        self.tabBarController?.selectedIndex = 4
    }
    
    
    // MARK: - object lifecycle
        
    // MARK: - view lifecycle
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        print("LOADING UP HOST STREAMING VIEW CONTROLLER")
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        print("HERES HOST: \(host)")
        print("HERE'S DJINFO: \(djInfo)")
    }
        
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setupBroadcastVC() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        print("SETTING UP BVC")
        //Make the request to create the stream
        let createdStreamInfo = createStream()
        let muxVC = sb.instantiateViewController(withIdentifier: "MuxViewController") as! MuxViewController
        muxVC.playbackStreamKey = createdStreamInfo["streamKey"]
        muxVC.djInfo = self.djInfo
        muxVC.host = self.host
        muxVC.modalPresentationStyle = .fullScreen
        self.present(muxVC, animated: true)
    }
    
    func createStream() -> [String:String] {
        print("CREATING STREAM")
        var hostPlaybackId = ""
        var hostPlaybackPolicy = ""
        var hostStreamKey = ""
        var success = "failed"
        let path = "https://api.mux.com/video/v1/live-streams"
        let parameters: [String: Any] = [
            "playback_policy": "public",
            "new_asset_settings": ["playback_policy": "public"]
        ]
        
        let url = URL(string: path)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let base64Auth = Data(Constants.AKTS.utf8).base64EncodedString() // base64encode the string
        request.setValue("Basic \(base64Auth)", forHTTPHeaderField: "Authorization") // add auth to headers
        request.httpMethod = "POST"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            request.httpBody = jsonData
            print(jsonData)
        } catch let error {
            //TODO: LET THE USER KNOW SOMETHING BAD HAS HAPPENED
            print(error.localizedDescription)
        }
        
        //Make Request
        let group = DispatchGroup()
        group.enter()
        session.dataTask(with: request) { data, response, error in
            print("MAKING REQUEST")
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {                                              // check for fundamental networking error
                //TODO: TELL USER ERROR OCCURRED
                print("error", error ?? "Unknown error")
                return
            }
            
            print(response.statusCode)
            guard (200 ... 299) ~= response.statusCode else { // check for http errors
                //TODO: TELL USER ERROR OCCURRED WHEN CREATING THE STREAM
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            if let dictionary = json as? [String:Any],
               let theData = dictionary["data"] as? [String:Any],
               let streamKey = theData["stream_key"] as? String,
               let playbackData = theData["playback_ids"] as? NSArray,
               let playbackIdData = playbackData[0] as? NSDictionary,
               let playbackId = playbackIdData["id"] as? String,
               let playbackPolicy = playbackIdData["policy"] as? String {
                print(theData)
                print("HERE IS THE PLAYBACKID: \(playbackId)")
                print("HERE IS THE PLAYBACK POLICY: \(playbackPolicy)")
                success = "success"
                hostPlaybackId = playbackId
                hostPlaybackPolicy = playbackPolicy
                hostStreamKey = streamKey
            } else {
                //TODO: TELL USER SOMETHING WENT WRONG
                print("DATA DOES NOT CONTAIN EXPECTEd INFO")
            }
            group.leave()
        }.resume()
        group.wait()
        let playbackData = [
            "playbackId": hostPlaybackId,
            "playbackPolicy": hostPlaybackPolicy,
            "streamKey": hostStreamKey
        ]
        if let username = host?.username {
            db.collection("hosts").document(username).setData([ "stream": playbackData ], merge: true)
        } else {
            print("username not present in host object")
        }
        return playbackData
    }
        
}
