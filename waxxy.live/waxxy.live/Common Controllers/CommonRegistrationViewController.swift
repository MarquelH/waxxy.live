//
//  CommonRegistrationViewController.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 10/28/20.
//  Copyright © 2020 Marquel Hendricks. All rights reserved.
//

import UIKit

class CommonRegistrationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var signUpIndicator: UIButton!
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if (usernameTextField.text == "" || passwordTextField.text == "" || confirmPasswordTextField.text == "") {
            //throw error
            print("ERROR ONE FIELD IS EMPTY")
        } else {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            if segmentedControl.selectedSegmentIndex == 0 {
                presentListenerRegistration(sb: sb, emailText: usernameTextField.text!, passwordText: passwordTextField.text!)
            } else {
                presentHostRegistration(sb: sb, emailText: usernameTextField.text!, passwordText: passwordTextField.text!)
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func registrationModeChanged(_ sender: Any) {
        if segmentedControl.selectedSegmentIndex == 0 {
            let img = UIImage(named: "music.mic")
            signUpIndicator.setBackgroundImage(img?.withTintColor(.systemPink), for: .normal)
        } else {
            let img = UIImage(named: "headphones")
            signUpIndicator.setBackgroundImage(img?.withTintColor(.systemPink), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        decorateTextField(textField: usernameTextField, placeholderText: "Email")
        decorateTextField(textField: passwordTextField, placeholderText: "Password")
        decorateTextField(textField: confirmPasswordTextField, placeholderText: "Confirm Password")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
    }
    
    func setupNavBar() {
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextPressed))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationItem.title = "Registration"
    }
    
    @objc func backToLoginView() {
        
    }
    
    @objc func nextPressed() {
        
    }
    
    func presentListenerRegistration(sb: UIStoryboard, emailText: String, passwordText: String) {
        print("PRESENTING LISTENER VC")
        let listenerRegController = sb.instantiateViewController(withIdentifier: "ListenerRegistrationViewController") as! ListenerRegistrationViewController
        listenerRegController.modalPresentationStyle = .fullScreen
        listenerRegController.email = emailText
        listenerRegController.password = passwordText
        self.present(listenerRegController, animated: true, completion: nil)
    }
    
    func presentHostRegistration(sb: UIStoryboard, emailText: String, passwordText: String) {
        let hostRegController = sb.instantiateViewController(withIdentifier: "HostRegistrationViewController") as! HostRegistrationViewController
        hostRegController.email = emailText
        hostRegController.password = passwordText
        hostRegController.modalPresentationStyle = .fullScreen
        self.present(hostRegController, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func decorateTextField(textField: UITextField, placeholderText: String) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height - 1, width: textField.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.white.cgColor
        textField.borderStyle = UITextField.BorderStyle.none
        textField.layer.addSublayer(bottomLine)
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
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
