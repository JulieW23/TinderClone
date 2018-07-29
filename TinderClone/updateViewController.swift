//
//  updateViewController.swift
//  TinderClone
//
//  Created by Julie Wang on 28/7/2018.
//  Copyright © 2018 Julie Wang. All rights reserved.
//

import UIKit
import Parse

class updateViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userGenderPicker: UIPickerView!
    @IBOutlet weak var genderInterestPicker: UIPickerView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var genderPickerData: [String] = [String]()
    var pickedGender = ""
    var genderInterestPickerData: [String] = [String]()
    var pickedInterestedGender = ""
    
    @IBAction func updateImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func updateProfile(_ sender: Any) {
        errorLabel.isHidden = true
        if pickedGender == "" {
            errorLabel.isHidden = false
            errorLabel.text = "Please pick your gender"
        } else if pickedInterestedGender == "" {
            errorLabel.isHidden = false
            errorLabel.text = "Please pick your interest"
        } else {
            PFUser.current()?["gender"] = pickedGender
            PFUser.current()?["interestedGender"] = pickedInterestedGender
            if let image = profileImageView.image {
                if let imageData = UIImagePNGRepresentation(image) {
                    PFUser.current()?["photo"] = PFFile(name: "profile.png", data: imageData)
                    PFUser.current()?.saveInBackground(block: { (success, error) in
                        if error != nil {
                            var errorMessage = "Update failed - try again"
                            if let newError = error as NSError? {
                                if let detailError = newError.userInfo["error"] as? String {
                                    errorMessage = detailError
                                }
                            }
                            self.errorLabel.isHidden = false
                            self.errorLabel.text = errorMessage
                        }
                        else {
                            print("update successful")
                            self.performSegue(withIdentifier: "updateToSwipeSegue", sender: nil)
                        }
                    })
                }
            }
        }
    }
    
    func displayPhotoWhenLoggedIn() {
        if let photo = PFUser.current()?["photo"] as? PFFile {
            photo.getDataInBackground { (data, error) in
                if let imageData = data {
                    if let image = UIImage(data: imageData) {
                        self.profileImageView.image = image
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        errorLabel.isHidden = true
        
        self.userGenderPicker.delegate = self
        self.userGenderPicker.dataSource = self
        self.genderInterestPicker.delegate = self
        self.genderInterestPicker.dataSource = self
        genderPickerData = ["", "Man", "Woman", "Other"]
        genderInterestPickerData = ["", "Man", "Woman", "Other", "Everybody"]
        
        if let gender = PFUser.current()?["gender"] as? String {
            if let index1 = genderPickerData.index(of: gender) {
                pickedGender = gender
                userGenderPicker.selectRow(index1, inComponent: 0, animated: false)
            }
        }
        if let interestedGender = PFUser.current()?["interestedGender"] as? String {
            if let index2 = genderInterestPickerData.index(of: interestedGender) {
                pickedInterestedGender = interestedGender
                genderInterestPicker.selectRow(index2, inComponent: 0, animated: false)
            }
        }
        displayPhotoWhenLoggedIn()
//        createWomen()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1{
            return genderPickerData.count
        }
        return genderInterestPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1{
            return genderPickerData[row]
        }
        return genderInterestPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            pickedGender = genderPickerData[row]
            print(pickedGender)
        } else {
            pickedInterestedGender = genderInterestPickerData[row]
            print(pickedInterestedGender)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createWomen() {
        let imageUrls = ["https://upload.wikimedia.org/wikipedia/en/7/76/Edna_Krabappel.png","https://static.comicvine.com/uploads/scale_small/0/40/235856-101359-ruth-powers.png","http://vignette3.wikia.nocookie.net/simpsons/images/f/fb/Serious-sam--cover.jpg/revision/latest?cb=20131109214146","https://s-media-cache-ak0.pinimg.com/736x/e4/42/5a/e4425aad73f01d36ace4c86c3156dcdc.jpg","http://www.simpsoncrazy.com/content/pictures/onetimers/LurleenLumpkin.gif","https://vignette2.wikia.nocookie.net/simpsons/images/b/bc/Becky.gif/revision/latest?cb=20071213001352","http://vignette3.wikia.nocookie.net/simpsons/images/b/b0/Woman_resembling_Homer.png/revision/latest?cb=20141026204206"]
        
        var counter = 0
        for imageUrl in imageUrls {
            counter += 1
            if let url = URL(string: imageUrl) {
                if let data = try? Data(contentsOf: url) {
                    let imageFile = PFFile(name: "photo.png", data: data)
                    let user = PFUser()
                    user["photo"] = imageFile
                    user["username"] = String(counter)
                    user["password"] = "password"
                    user["gender"] = genderPickerData[2]
                    user["interestedGender"] = genderInterestPickerData[2]
                    user.signUpInBackground { (success, error) in
                        if success {
                            print("created user")
                        }
                    }
                }
            }
        }
    }

}
