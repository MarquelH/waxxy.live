//
//  ConnectViewController.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 11/6/20.
//  Copyright © 2020 Marquel Hendricks. All rights reserved.
//

import UIKit
import Hue

public protocol ConnectDelegate: NSObjectProtocol {
    func connectViewController(_ viewController: ConnectViewController, didConnectWithStreamKey streamKey: String)
}

public class ConnectViewController: UIViewController {

    // MARK: - properties
    
    public weak var connectDelegate: ConnectDelegate?
    
    private var _logoView: UIImageView?
    private var _textField: UITextField?
    private var _startButton: MuxButton?
    private var _textBox: UITextView?
    
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
        
        print("CONNECT VIEW CONTROLLER LOADING")
        self.view.backgroundColor = UIColor.white
        self.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.layer.cornerRadius = 12.0
        
        self._logoView = UIImageView(image: UIImage(named: "mux_logo"))
        if let logoView = self._logoView {
            logoView.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY - (self.view.bounds.size.height * 0.2))
            self.view.addSubview(logoView)
        }
        
        self._textField = UITextField(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width - (20 * 2), height: 40))
        if let textField = self._textField,
            let logoView = self._logoView {
            textField.delegate = self
            textField.keyboardType = .URL
            textField.returnKeyType = .done
            textField.borderStyle = .none
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .default
            textField.spellCheckingType = .no
            textField.clearButtonMode = .never
            textField.tintColor = UIColor(hex: "#fb3064")
            textField.textColor = UIColor.black
            textField.background = UIImage(named: "textfield_inactive")
            textField.attributedPlaceholder = NSAttributedString(string: "stream key or URL", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
            textField.center = CGPoint(x: self.view.bounds.midX, y: logoView.frame.maxY + 45.0 + 20.0)
            self.view.addSubview(textField)

        }
        
        self._startButton = MuxButton(type: .custom)
        if let startButton = self._startButton,
            let textField = self._textField {
            startButton.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width - (20 * 2), height: 50)
            startButton.setTitleColor(UIColor.white, for: .normal)
            startButton.setTitle("Start Broadcast", for: .normal)
            startButton.setTitle("Starting…", for: .disabled)
            startButton.layer.cornerRadius = startButton.frame.height * 0.5
            startButton.backgroundColor = UIColor(hex: "#fb2490")
            startButton.addTarget(self, action: #selector(handleStartButton(_:)), for: .touchUpInside)
            startButton.center = CGPoint(x: self.view.bounds.midX, y: textField.frame.maxY + 25.0 + 20.0)
            self.view.addSubview(startButton)
        }
        
        self._textBox = UITextView(frame: CGRect(x: 20, y: self.view.bounds.size.height - 100, width: self.view.bounds.size.width - 40, height: 100))
        if let textBox = self._textBox {
            textBox.text = "Note: streaming from a simulator will not work because the simulator does not have access to a camera."
            textBox.backgroundColor = UIColor.white
            textBox.textColor = UIColor.black
            self.view.addSubview(textBox)
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _textField?.resignFirstResponder()
    }
}

// MARK: - internal
extension ConnectViewController {
    
    internal func startStream() {
        if let text = self._textField?.text,
            text.count > 0 {
            self.view.isUserInteractionEnabled = false
            self._startButton?.isEnabled = false
            self.connectDelegate?.connectViewController(self, didConnectWithStreamKey: text)
            self.dismiss(animated: true, completion: nil)
        }
    
    }
}

// MARK: -  status bar
extension ConnectViewController {
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .default
        }
    }
    
}

// MARK: - UIButton
extension ConnectViewController {
    
    @objc public func handleStartButton(_ button: UIButton) {
        self.startStream()
    }
    
}

// MARK: - UITextFieldDelegate
extension ConnectViewController: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.background = UIImage(named: "textfield_active")
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.background = UIImage(named: "textfield_inactive")
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.startStream()
        return true
    }
    
}

public class MuxButton: UIButton {

    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor(hex: "#fb2490").alpha(0.7) : UIColor(hex: "#fb2490")
        }
    }

}
