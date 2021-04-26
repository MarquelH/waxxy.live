//
//  ListenerRegistrationViewController.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 10/29/20.
//  Copyright © 2020 Marquel Hendricks. All rights reserved.
//

import UIKit
import WSTagsField
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class ListenerRegistrationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var topGenresTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topGenresView: UIView!
    var db: Firestore!
    var email = ""
    var password = ""
    
    let tagsField = WSTagsField()
    var genreTags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        topGenresView.layer.cornerRadius = 15
        topGenresView.layer.masksToBounds = true
        decorateTextField(textField: usernameTextField, placeholderText: "Username")
        setupTagTextField(tagsView: topGenresView)
        usernameTextField.delegate = self
        // [START setup]
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
    }
    
    @IBAction func finishPressed(_ sender: Any) {
        print(genreTags)
        //add genre tags &
        addUserToDB()
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func decorateTextField(textField: UITextField, placeholderText: String) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: textField.frame.height - 1, width: textField.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.white.cgColor
        textField.borderStyle = UITextField.BorderStyle.none
        textField.layer.addSublayer(bottomLine)
        textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    func setupTagTextField(tagsView: UIView) {
        tagsField.frame = tagsView.bounds
        tagsView.addSubview(tagsField)

        //tagsField.translatesAutoresizingMaskIntoConstraints = false
        //tagsField.heightAnchor.constraint(equalToConstant: 79).isActive = true
        tagsField.cornerRadius = 3.0
        tagsField.spaceBetweenLines = 10
        tagsField.spaceBetweenTags = 10

        //tagsField.numberOfLines = 1
        //tagsField.maxHeight = 100.0
        tagsField.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        tagsField.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) //old padding
        tagsField.placeholder = "Top Genre(s)"
        tagsField.placeholderColor = .darkGray
        tagsField.placeholderAlwaysVisible = false
        tagsField.backgroundColor = .clear
        tagsField.textField.returnKeyType = .next
        tagsField.delimiter = ""
        
        tagsField.textColor = .white
        tagsField.selectedColor = .red
        tagsField.selectedTextColor = .white

        tagsField.textDelegate = self
        textFieldEvents()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tagsField.frame = topGenresView.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func makeRounded(image: UIImageView) {
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.cornerRadius = image.frame.height/2 //This will change with corners of image and height/2 will make this circle shape
        image.clipsToBounds = true
    }
    
    func addUserToDB() {
        //TODO VALIDATE EMAIL & PWD BEFORE ENTERING INTO API CALL
        print(self.password)
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                print(self.password)
                //An error happened, print to console & tell user
                print(error.localizedDescription)
            } else {
                //Save user info in db
                guard let username = self.usernameTextField.text else { return }
                var docData: [String: Any] = [
                    "email": self.email,
                    "username": username,
                    "topGenres": self.genreTags
                ]
                self.db.collection("listeners").document(username).setData(docData) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        let sb = UIStoryboard(name: "Main", bundle: nil)
                        let listenersTabBar = sb.instantiateViewController(withIdentifier: "ListenersTabBarController") as! ListenersTabBarController
                        listenersTabBar.modalPresentationStyle = .fullScreen
                        listenersTabBar.guestInfo = docData
                        self.present(listenersTabBar, animated: true, completion: nil)
                        print("Document successfully written!")
                    }
                }
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

extension ListenerRegistrationViewController {

    fileprivate func textFieldEvents() {
        tagsField.onDidAddTag = { field, tag in
            print("onDidAddTag", tag.text)
            self.genreTags.append(tag.text)
        }

        tagsField.onDidRemoveTag = { field, tag in
            print("onDidRemoveTag", tag.text)
            var idx = 0
            for genreTag in self.genreTags {
                if tag.text == genreTag {
                    self.genreTags.remove(at: idx)
                }
                idx = idx + 1
            }
        }

        tagsField.onDidChangeText = { _, text in
            print("onDidChangeText")
        }

        tagsField.onDidChangeHeightTo = { _, height in
            print("HeightTo \(height)")
        }

        tagsField.onDidSelectTagView = { _, tagView in
            print("Select \(tagView)")
        }

        tagsField.onDidUnselectTagView = { _, tagView in
            print("Unselect \(tagView)")
        }

        tagsField.onShouldAcceptTag = { field in
            return field.text != "OMG"
        }
    }

}
