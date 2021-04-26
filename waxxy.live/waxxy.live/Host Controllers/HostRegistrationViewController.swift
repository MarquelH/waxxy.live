//
//  HostRegistrationViewController.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 10/29/20.
//  Copyright © 2020 Marquel Hendricks. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class HostRegistrationViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var topGenresText: UITextField!
    @IBOutlet weak var hostTypeText: UITextField!
    @IBOutlet weak var regionText: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    var db: Firestore!
    var email = ""
    var password = ""
    var pickerView = UIPickerView()
    let hostTypes: [String] = ["DJ", "Artist/MC", "Podcaster"]
    
    let toolbar: UIToolbar = {
        let tb = UIToolbar()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleToolBarDone))
        doneButton.tintColor = UIColor(red: 75/255, green: 215/255, blue: 100/255, alpha: 1)
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleToolBarCancel))
        cancelButton.tintColor = UIColor(red: 75/255, green: 215/255, blue: 100/255, alpha: 1)
        tb.barTintColor = UIColor.white
        tb.barStyle = .default
        tb.isTranslucent = true
        tb.tintColor = UIColor(red: 75/255, green: 215/255, blue: 100/255, alpha: 1)
        tb.sizeToFit()
        tb.setItems([cancelButton, spacer, doneButton], animated: true)
        return tb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        usernameText.delegate = self
        topGenresText.delegate = self
        hostTypeText.delegate = self
        regionText.delegate = self
        pickerView.delegate = self
        decorateTextField(textField: usernameText, placeholderText: "Username")
        decorateTextField(textField: topGenresText, placeholderText: "Top Genre(s)")
        decorateTextField(textField: hostTypeText, placeholderText: "Host Type")
        decorateTextField(textField: regionText, placeholderText: "Hometown Region")
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addPhotoButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        addPhotoButton.widthAnchor.constraint(equalTo: profileImageView.widthAnchor, multiplier: 1).isActive = true
        addPhotoButton.heightAnchor.constraint(equalTo: profileImageView.heightAnchor, multiplier: 1).isActive = true
        hostTypeText.addTarget(self, action: #selector(hostTypeClicked), for: UIControl.Event.editingDidBegin)
    }
    
    func makeRounded(image: UIImageView) {
        image.layer.borderWidth = 1
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.cornerRadius = image.frame.height/2 //This will change with corners of image and height/2 will make this circle shape
        image.clipsToBounds = true
    }
    
    func addUserToDB() {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                //An error happened, print to console & tell user
                print(error.localizedDescription)
            } else {
                //Save user info in db
                guard let username = self.usernameText.text, let topGenres = self.topGenresText.text,
                    let hostType = self.hostTypeText.text, let region = self.regionText.text else { return }
                var docData: [String: Any] = [
                    "email": self.email,
                    "username": username,
                    "topGenres": topGenres,
                    "hostType": hostType,
                    "region": region,
                    "numSubscribers": 0
                ]
                self.db.collection("hosts").document(username).setData(docData) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        let sb = UIStoryboard(name: "Main", bundle: nil)
                        let hostTabBarController = sb.instantiateViewController(withIdentifier: "hostTabBar")
                        hostTabBarController.modalPresentationStyle = .fullScreen
                        self.present(hostTabBarController, animated: true, completion: nil)
                        print("Document successfully written!")
                    }
                }
                
            }
        }
    }
    
    @IBAction func finishTapped(_ sender: Any) {
        addUserToDB()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPhotoTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
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
    
    //columns
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hostTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        hostTypeText.text = hostTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return hostTypes[row]
    }
    
    @objc func hostTypeClicked() {
        hostTypeText.inputView = pickerView
        hostTypeText.inputAccessoryView = toolbar
    }
    
    @objc func handleToolBarDone() {
        self.view.endEditing(true)
    }
    
    @objc func handleToolBarCancel() {
        self.view.endEditing(true)
    }
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        print("WE ARE IN THIS METHOD")
        var selectedImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        
        if let selectedImageFromPicker = selectedImage {
            profileImageView.image = selectedImageFromPicker
            addPhotoButton.setTitle("Edit\nPhoto", for: .normal)
        }
        dismiss(animated: true, completion: nil)
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
