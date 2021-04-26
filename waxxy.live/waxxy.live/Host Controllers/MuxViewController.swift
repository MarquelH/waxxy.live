import UIKit
import RPCircularProgress
import Hue
import FirebaseFirestore
import FirebaseFirestoreSwift
//import MuxLive
public class MuxViewController: UIViewController {

    // MARK: - properties
    
    private var _broadcastViewController: MuxBroadcastViewController?
    
    private var _stopButton: UIButton?
    private var _cameraFlipButton: UIButton?
    private var _watchersButton: UIButton?
    public var _watcherCount: UILabel?
    private var _streamStatusProgress: RPCircularProgress?
    public var playbackStreamKey: String?
    var db: Firestore!
    var djInfo = [String: Any?]()
    var isFrontFacing: Bool?
    var host: Host?
    
    // MARK: - object lifecycle
    
    // MARK: - view lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        //setup a broadcast view controller
        self._broadcastViewController = MuxBroadcastViewController()
        if let viewController = self._broadcastViewController {
            viewController.muxBroadcasterDelegate = self
            viewController.start(withStreamKey: self.playbackStreamKey!, interfaceOrientation: .portrait)
            isFrontFacing = true
            self.addChild(viewController)
            //viewController.view.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.view.addSubview(viewController.view)
            viewController.didMove(toParent: self)
            //self.definesPresentationContext = true
            //viewController.modalPresentationStyle = .overCurrentContext
            //self.present(viewController, animated: true)
        }
        
        var safeAreaTop: CGFloat = UIApplication.shared.statusBarFrame.size.height
        if let window = UIApplication.shared.keyWindow {
            if window.safeAreaInsets.top > 0 {
                safeAreaTop = window.safeAreaInsets.top
            }
        }
        let margin: CGFloat = 15.0
        
        self._streamStatusProgress = RPCircularProgress()
        if let streamStatusProgress = self._streamStatusProgress {
            streamStatusProgress.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            streamStatusProgress.roundedCorners = true
            streamStatusProgress.thicknessRatio = 0.4
            streamStatusProgress.trackTintColor = UIColor(hex: "#221e1f")
            streamStatusProgress.progressTintColor = UIColor(hex: "#fb3064")
            streamStatusProgress.isUserInteractionEnabled = false
            streamStatusProgress.center = CGPoint(x: self.view.bounds.width - (streamStatusProgress.frame.height * 0.5) - margin,
                                                  y: (streamStatusProgress.frame.width * 0.5) + margin + safeAreaTop)
            //self.view.addSubview(streamStatusProgress)
        }
        
        self._stopButton = UIButton(type: .custom)
        if let stopButton = self._stopButton {
            stopButton.setImage(UIImage(named: "stop"), for: .normal)
            stopButton.sizeToFit()
            stopButton.addTarget(self, action: #selector(handleStopButton(_:)), for: .touchUpInside)
            stopButton.center = CGPoint(x: (stopButton.frame.height * 0.5) + margin,
                                        y: (stopButton.frame.width * 0.5) + margin + safeAreaTop)
            self.view.addSubview(stopButton)
        }
        
        self._cameraFlipButton = UIButton(type: .custom)
        if let cfButton = self._cameraFlipButton {
            cfButton.setImage(UIImage(named: "rotate-3"), for: .normal)
            cfButton.sizeToFit()
            cfButton.addTarget(self, action: #selector(handleCameraFlip), for: .touchUpInside)
            cfButton.center = CGPoint(x: self.view.bounds.width - (cfButton.frame.height * 0.5) - margin, y: (cfButton.frame.width * 0.5) + margin + safeAreaTop)
            self.view.addSubview(cfButton)
        }
        
        self._watchersButton = UIButton(type: .custom)
        if let wButton = self._watchersButton {
            wButton.setImage(UIImage(systemName: "eye"), for: .normal)
            wButton.sizeToFit()
            wButton.addTarget(self, action: #selector(handleWatchersPopup), for: .touchUpInside)
            wButton.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(wButton)
        }
        
        self._watcherCount = UILabel()
        if let wCount = self._watcherCount {
            wCount.text = "0"
            wCount.textColor = .black
            wCount.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(wCount)
        }
        setupConstraints()
    }
    
    func setupConstraints() {
        self._watchersButton!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self._watchersButton!.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        
        self._watcherCount!.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self._watcherCount!.leftAnchor.constraint(equalTo: self._watchersButton!.rightAnchor).isActive = true
        
        /*mainview.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
         mainview.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
         mainview.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
         mainview.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true*/
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self._streamStatusProgress?.enableIndeterminate(false, completion: nil)
    }
    
}

// MARK: -  status bar
extension MuxViewController {
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
}

// MARK: - internal
extension MuxViewController {
    
    public func presentConnectModal(animated: Bool = true) {
        let connectViewController = ConnectViewController()
        connectViewController.connectDelegate = self
        connectViewController.modalPresentationStyle = .currentContext
        connectViewController.modalTransitionStyle = .coverVertical
        UIApplication.presentViewControllerFromRoot(viewController: connectViewController, animated: animated)
    }
    
}

// MARK: - UIButton
extension MuxViewController {
    
    @objc public func handleStopButton(_ button: UIButton) {
        self._broadcastViewController?.stop()
        if host != nil {
            //DELETE THE STREAM THROUGH THE API
            //IMPLEMENT A BUTTON FOR PIP
            db.collection("hosts").document(host!.username!).updateData([
                "stream": FieldValue.delete(),
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        } else {
            //TODO CATCH THIS ERROR AND REPORT
            print("NO HOST PASSED IN")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc public func handleCameraFlip() {
        if isFrontFacing! {
            self._broadcastViewController?._muxLive._liveSession?.captureDevicePosition = .back
            isFrontFacing = false
        } else {
            self._broadcastViewController?._muxLive._liveSession?.captureDevicePosition = .front
            isFrontFacing = true
        }
    }
    
    @objc public func handleWatchersPopup() {
        
    }
}

// MARK: - MuxBroadcasterDelegate
extension MuxViewController: MuxBroadcasterDelegate {
    
    public func muxBroadcaster(_ muxBroadcaster: MuxBroadcastViewController, didChangeState state: MuxLiveState) {
        print("🎬 MuxLive didChangeState, \(state.description)")
        
        switch state {
        case .ready:
            fallthrough
        case .stopped:
            // solid off-black ring
            self._streamStatusProgress?.progressTintColor = UIColor(hex: "#fb3064")
            self._streamStatusProgress?.updateProgress(0, animated: true, initialDelay: 0, completion: nil)
            self._streamStatusProgress?.enableIndeterminate(false, completion: nil)
            break
        case .pending:
            fallthrough
        case .retrying:
            // spinning red ring
            self._streamStatusProgress?.progressTintColor = UIColor(hex: "#fb3064")
            self._streamStatusProgress?.updateProgress(0.3, animated: true, initialDelay: 0, completion: nil)
            self._streamStatusProgress?.enableIndeterminate(true, completion: nil)
            break
        case .started:
            // solid red ring
            self._streamStatusProgress?.progressTintColor = UIColor(hex: "#fb3064")
            self._streamStatusProgress?.updateProgress(1.0, animated: true, initialDelay: 0, completion: nil)
            self._streamStatusProgress?.enableIndeterminate(false, completion: nil)
            break
        case .failed:
            // solid yellow ring
            self._streamStatusProgress?.progressTintColor = UIColor(hex: "#f7df48")
            self._streamStatusProgress?.updateProgress(1.0, animated: true, initialDelay: 0, completion: nil)
            self._streamStatusProgress?.enableIndeterminate(false, completion: nil)
            break
        }
    }

}

// MARK: - ConnectDelegate
extension MuxViewController: ConnectDelegate {
    
    public func connectViewController(_ viewController: ConnectViewController, didConnectWithStreamKey streamKey: String) {
        // start a broadcast stream
        //self._broadcastViewController?.start(withStreamKey: streamKey, interfaceOrientation: UIApplication.shared.statusBarOrientation)
    }
    
}
