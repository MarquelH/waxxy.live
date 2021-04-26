//
//  HostSideProfileViewController.swift
//  waxxy.live
//
//  Created by Marquel Hendricks on 12/22/20.
//  Copyright © 2020 Marquel Hendricks. All rights reserved.
//

import UIKit
import WSTagsField

class HostSideProfileViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var hostNameAndTypeLabel: UILabel!
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var numSubscribersLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var topGenreTagsView: UIView!
    
    var djInfo: NSDictionary!
    var host: Host?
    var isEditingProfile: Bool?
    
    let tagsField = WSTagsField()
    var genreTags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTagTextField(tagsView: topGenreTagsView)
        editButton.layer.cornerRadius = 15
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let hostInfo = host else {
            print("SOMETHING HAS GONE WRONG")
            return
        }
        hostNameAndTypeLabel.text = "\(hostInfo.username)    |   \(hostInfo.hostType)"
        regionLabel.text = hostInfo.region
        numSubscribersLabel.text = String(hostInfo.numSubscribers)
        self.genreTags = hostInfo.topGenres!
    }
    
    func setupTagTextField(tagsView: UIView) {
        tagsField.frame = tagsView.bounds
        tagsView.addSubview(tagsField)
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

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension HostSideProfileViewController {

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
