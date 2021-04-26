//
//  ListenerSettingsViewController.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 1/13/21.
//  Copyright © 2021 Marquel Hendricks. All rights reserved.
//

import UIKit
import WSTagsField

class ListenerSettingsViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var topGenresView: UIView!
    var guestInfo = [String: Any?]()
    var listener: Listener?
    let tagsField = WSTagsField()
    var genreTags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.usernameLabel.text = guestInfo["username"] as! String
        self.genreTags = guestInfo["topGenres"] as! [String]
        setupTagTextField(tagsView: topGenresView)
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
        //Add the User's existing tags
        tagsField.addTags(self.genreTags)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ListenerSettingsViewController {

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
