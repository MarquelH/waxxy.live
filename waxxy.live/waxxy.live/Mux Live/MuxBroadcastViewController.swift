//
//  MuxBroadcastViewController.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 11/6/20.
//  Copyright © 2020 Marquel Hendricks. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import NextLevel

/// MuxBroadcasterDelegate, callback delegation for the broadcaster
public protocol MuxBroadcasterDelegate: AnyObject {
    func muxBroadcaster(_ muxBroadcaster: MuxBroadcastViewController, didChangeState state: MuxLiveState)
}

/// MuxBroadcastViewController, provides a simple user interface and permissions handling for MuxLive streaming
public class MuxBroadcastViewController: UIViewController {
    
    // MARK: - properties
    
    public weak var muxBroadcasterDelegate: MuxBroadcasterDelegate?
    
    public var liveState: MuxLiveState {
        get {
            return self._muxLive.liveState
        }
    }
    
    // MARK: - ivars
    
    internal var _previewView: UIView?
    internal var _muxLive: MuxLive = MuxLive()
    
    // MARK: - object lifecycle
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("not supported")
    }
    
    // MARK: - view lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        print("LOADING UP MUX BROADCAST VC")
        
        self.view.backgroundColor = UIColor.black
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // setup MuxLive and preview
        self._previewView = UIView(frame: self.view.bounds)
        if let previewView = self._previewView {
            self._muxLive.muxLiveDelegate = self
            self._muxLive.previewView = previewView
            self.view.addSubview(previewView)
        }
        
        // check permissions
        self.checkAndRequestCameraPermission()
        self.checkAndRequestMicrophonePermission()
    }
    
    func flipCamera() {
        //self._muxLive.liveS
    }

    private func getInterfaceOrientationMask() -> UIInterfaceOrientationMask {
        switch self.interfaceOrientation {
        case .unknown:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .portrait:
            return .portrait
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self._muxLive.isRunning = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self._muxLive.isRunning = false
        print("STOPPING")
        self._muxLive.stop()
    }
    
}

// MARK: -  status bar
extension MuxBroadcastViewController {
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
}

// MARK: - MuxLiveDelegate
extension MuxBroadcastViewController: MuxLiveDelegate {
    
    public func muxLive(_ muxLive: MuxLive, didChangeState state: MuxLiveState) {
        self.muxBroadcasterDelegate?.muxBroadcaster(self, didChangeState: state)
    }
    
    public func muxLive(_ muxLive: MuxLive, didFailWithError error: Error) {
#if DEBUG
        print("MuxLive encountered an error, \(error)")
#endif
    }
    
    

}

// MARK: - actions
extension MuxBroadcastViewController {
    
    /// Start a MuxLive stream
    ///
    /// - Parameter streamKey: stream_key from api.mux.com
    public func start(withStreamKey streamKey: String, interfaceOrientation: UIInterfaceOrientation) {
        print("STARTING MUX LIVE with stream key: \(streamKey)")
        self._muxLive.start(withStreamKey: streamKey, interfaceOrientation)
    }
    
    /// Stop a MuxLive stream
    public func stop() {
        print("STOPPING")
        self._muxLive.stop()
    }
    
}

// MARK: - permissions
extension MuxBroadcastViewController {
    
    /// Launch app settings
    ///
    /// - Parameters:
    ///   - title: Message title string
    ///   - message: Alert message
    open func launchAppSettings(withTitle title: String = NSLocalizedString("⚙️ settings", comment: "⚙️ settings"),
                                  message: String = NSLocalizedString("would you like to open settings?", comment: "would you like to open settings?")) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("open", comment: "open"), style: UIAlertAction.Style.default) {
            (action: UIAlertAction) in
            print("UIAlertAction open completion handler");
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: UIAlertAction.Style.cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Check and request camera permission
    open func checkAndRequestCameraPermission() {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                    return
                    // The user has previously granted access to the camera.
                    //self.setupCaptureSession()
                
                case .notDetermined: // The user has not yet been asked for camera access.
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        if granted {
                            //self.setupCaptureSession()
                        }
                    }
                
                case .denied: // The user has previously denied access.
                    return

                case .restricted: // The user can't grant access due to restrictions.
                    return
            }
    }
    
    /// Check and request mic permission
    open func checkAndRequestMicrophonePermission() {
            //Request auth
            switch AVCaptureDevice.authorizationStatus(for: .audio) {
            case .authorized:
                    return
                    // The user has previously granted access to the camera.
                    //self.setupCaptureSession()
                
                case .notDetermined: // The user has not yet been asked for camera access.
                    AVCaptureDevice.requestAccess(for: .video) { granted in
                        if granted {
                            //self.setupCaptureSession()
                        }
                    }
                
                case .denied: // The user has previously denied access.
                    return

                case .restricted: // The user can't grant access due to restrictions.
                    return
            }
    }
    
}
