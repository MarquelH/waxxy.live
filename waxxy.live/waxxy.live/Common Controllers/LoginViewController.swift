//
//  ViewController.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 9/7/20.
//  Copyright © 2020 Marquel Hendricks. All rights reserved.
//

import UIKit
import CoreData
import AuthenticationServices
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import Firebase
import FirebaseFirestoreSwift

class LoginViewController: UIViewController, UITextFieldDelegate {

    var listeners: [NSManagedObject] = []

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var hostOrListenerSegmentedControl: UISegmentedControl!
    var db: Firestore!
    var djInfo = [String: Any?]()
    var guestInfo = [String: Any?]()
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        decorateTextField(textField: emailTextField, placeholderText: "Email")
        decorateTextField(textField: passwordTextField, placeholderText: "Password")
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

    @IBAction func didPressBaseLoginButton(_ sender: Any) {
        print("BASE LOGIN PRESSED")
        var isHost = false
        var host: Host?
        var listener: Listener?
        if self.hostOrListenerSegmentedControl.selectedSegmentIndex == 1 {
            //TODO GET DJ'S DATA
            isHost = true
            print("ISHOST")
            host = Host(entity: Host.entity(), insertInto: self.context)
            db.collection("hosts").whereField("email", isEqualTo: emailTextField.text!)
                .getDocuments { (querySnap, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        let hostInfo = querySnap!.documents.first!.data()
                        if let username = hostInfo["username"] as? String,
                           let region = hostInfo["region"] as? String,
                           let topGenres = hostInfo["topGenres"] as? String,
                           let hostType = hostInfo["hostType"] as? String,
                           let email = hostInfo["email"] as? String {
                            host!.username = username
                            host!.region = region
                            let topGenresSplit = topGenres.components(separatedBy: ",")
                            host!.topGenres = topGenresSplit
                            host!.hostType = hostType
                            host!.email = email
                           } else {
                            print("SOMETHING WENT WRONG")
                           }
                    }
            }
        } else {
            isHost = false
            print("IS NOT HOST")
            listener = Listener(entity: Listener.entity(), insertInto: self.context)
            db.collection("guests").whereField("email", isEqualTo: emailTextField.text!)
                .getDocuments { (querySnap, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        let listenerInfo = querySnap!.documents.first!.data()
                        if let listenerName = listenerInfo["username"] as? String,
                           let listenerTopGenres = listenerInfo["topGenres"] as? [String],
                           let listenerEmail = listenerInfo["email"] as? String {
                            let newSubsciptionsArray = [String]()
                            listener!.username = listenerName
                            listener!.email = listenerEmail
                            listener!.topGenres = listenerTopGenres
                            listener!.subscriptions = newSubsciptionsArray
                        } else {
                            print("SOMETHING WENT WRONG")
                        }
                    }
                }
        }
        signIn(emailText: emailTextField.text!, passwordText: passwordTextField.text!, isHostSignIn: isHost, host: host, listener: listener)
    }
    @IBAction func didPressFBLogin(_ sender: Any) {
        //Gather info from FB & save name & email
    }
    @IBAction func didPressGoogleLogin(_ sender: Any) {
        //Gather info from Google & save name & email
    }
    @IBAction func didPressAppleLogin(_ sender: Any) {
        //Gather info from Apple & save name & email
    }
    @IBAction func nativeRegistrationPressed(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let commonRegController = sb.instantiateViewController(withIdentifier: "CommonRegistrationViewController") as! CommonRegistrationViewController
        //self.definesPresentationContext = true
        commonRegController.modalPresentationStyle = .fullScreen
        self.present(commonRegController, animated: true, completion: nil)
    }
    
    @IBAction func closePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    func save(name: String, email: String) {
      
      guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
        return
      }
      
      // 1
      let managedContext =
        appDelegate.persistentContainer.viewContext
      
      // 2
      let entity =
        NSEntityDescription.entity(forEntityName: "Listener",
                                   in: managedContext)!
      
      let listener = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
      
      // 3
        listener.setValue(name, forKey: "name")
        listener.setValue(email, forKey: "email")
      
      // 4
      do {
        try managedContext.save()
        listeners.append(listener)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    func signIn(emailText: String, passwordText: String, isHostSignIn: Bool, host: Host?, listener: Listener?) {
        //Name and email would have been saved from our signup
        Auth.auth().signIn(withEmail: emailText, password: passwordText) { (authResult, error) in
            if let error = error {
                //An error happened, print to console & tell user
                print(error.localizedDescription)
            } else {
                print("NO ERROR WITH SIGN IN ")
                let sb = UIStoryboard(name: "Main", bundle: nil)
                
                if isHostSignIn {
                    let hostTabBarController = sb.instantiateViewController(withIdentifier: "hostTabBar") as! HostTabBarController
                    hostTabBarController.modalPresentationStyle = .overFullScreen
                    DispatchQueue.main.async {
                        //hostTabBarController.djInfo = djInfo
                        hostTabBarController.host = host
                        self.present(hostTabBarController, animated: true, completion: nil)
                    }
                } else {
                    let listenerTabController = sb.instantiateViewController(identifier: "listenerTabBar") as! ListenersTabBarController
                    listenerTabController.modalPresentationStyle = .overFullScreen
                    DispatchQueue.main.async {
                        listenerTabController.listener = listener
                        self.present(listenerTabController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    private func handleAppleAuthentication() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.presentationContextProvider = self
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        //sign in with firebase?? and store user into cache
        //Token stuff?
        save(name: appleCredential.fullName!.description, email: appleCredential.email!)
    }
}

extension LoginViewController {
    private func handleFBAuthentication() {
        
    }
}

