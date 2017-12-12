//
//  SecondViewController.swift
//  TwitterC
//
//  Created by Laurentiu Rogean on 24/10/2017.
//  Copyright © 2017 Laurentiu Rogean. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var displayNameField: UITextField!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        picker.delegate = self
        
        profileImage.layer.cornerRadius = 40
        profileImage.layer.borderColor = view.tintColor.cgColor
        profileImage.layer.borderWidth = 0.5
        profileImage.layer.masksToBounds = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let userName = TwitterClient.sharedInstance.userName, let profileImageUrl = TwitterClient.sharedInstance.profileBannerURL, let name = TwitterClient.sharedInstance.name {
            usernameLabel.text = "@" + userName
            nameLabel.text = name
            profileImage.sd_setImage(with: profileImageUrl, placeholderImage: UIImage(named: "placeholderavatar"))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logOut(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Log out", message: "Are you sure?", preferredStyle: UIAlertControllerStyle.alert)
        
        let destructiveAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive) {
            (result : UIAlertAction) -> Void in
            TwitterClient.sharedInstance.logOut()
            self.tabBarController?.selectedIndex = 0
        }

        let okAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(destructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeImage(_ sender: Any) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func submitChange(_ sender: Any) {
        if (displayNameField.text?.isEmpty)! {
            presentAlertController(title: "Empty field", message: "You have not entered a new name to be displayed!")
        } else {
            TwitterClient.sharedInstance.changeDisplayedName(newName: displayNameField.text!)
            nameLabel.text = displayNameField.text!
            displayNameField.text?.removeAll()
            presentAlertController(title: "Success", message: "The name was updated successfully!")
        }
    }
    
    // MARK: - UIImagePickerController Delegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImagePNGRepresentation(chosenImage)
        let encodedImage = imageData?.base64EncodedString()
        TwitterClient.sharedInstance.changeProfileBanner(encodedImage: encodedImage!)
        profileImage.image = chosenImage
        picker.dismiss(animated: true) {
            DispatchQueue.main.async {
                self.profileImage.image = chosenImage
                self.profileImage.contentMode = UIViewContentMode.scaleAspectFit
            }
        }
    }
    
    // MARK: - Utils
    
    func presentAlertController(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

