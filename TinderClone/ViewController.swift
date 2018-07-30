//
//  ViewController.swift
//  TinderClone
//
//  Created by Julie Wang on 27/7/2018.
//  Copyright © 2018 Julie Wang. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    var displayUserID = ""

    @IBOutlet weak var matchImageView: UIImageView!
    
    @IBAction func viewOwnProfile(_ sender: Any) {
        performSegue(withIdentifier: "viewOwnProfileSegue", sender: nil)
    }
    @IBAction func logout(_ sender: Any) {
        PFUser.logOut()
        performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //add gesture recognizer to swipe label
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        matchImageView.addGestureRecognizer(gesture)
        updateImage()
        PFGeoPoint.geoPointForCurrentLocation { (geoPoint, error) in
            if let point = geoPoint {
                PFUser.current()?["location"] = point
                PFUser.current()?.saveInBackground()
            }
        }
    }
    
    // respond when swipeLabel is dragged
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        let labelPoint = gestureRecognizer.translation(in: view)
        
        // make label move when dragged
        matchImageView.center = CGPoint(x: view.bounds.width / 2 + labelPoint.x, y: view.bounds.height / 2 + labelPoint.y)
        // pretty rotating of label
        let xFromCenter = view.bounds.width / 2 - matchImageView.center.x
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 300)
        // pretty shrinking of label
        let scale = min(100 / abs(xFromCenter), 1)
        var scaledAndRotated = rotation.scaledBy(x: scale, y: scale)
        matchImageView.transform = scaledAndRotated
        
        // detect when dragged left/right a certain distance
        if gestureRecognizer.state == .ended {
            var acceptedOrRejected = ""
            let threshold = CGFloat(150)
            if matchImageView.center.x < (view.bounds.width / 2 - threshold) {
                print("Not interested")
                acceptedOrRejected = "rejected"
            } else if matchImageView.center.x > (view.bounds.width / 2 + threshold) {
                print("Interested")
                acceptedOrRejected = "accepted"
            }
            if acceptedOrRejected != "" && displayUserID != ""{
                PFUser.current()?.addUniqueObject(displayUserID, forKey: acceptedOrRejected)
                PFUser.current()?.saveInBackground(block: { (success, error) in
                    if success {
                        self.updateImage()
                    }
                })
            }
            rotation = CGAffineTransform(rotationAngle: 0)
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)
            matchImageView.transform = scaledAndRotated
            matchImageView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        }
    }
    
    // find all users that fit requirements, and pick one to display
    func updateImage() {
        if let query = PFUser.query() {
            if let interestedGender = PFUser.current()?["interestedGender"] {
                query.whereKey("gender", equalTo: interestedGender)
            }
            if let interestedGender = PFUser.current()?["gender"] {
                query.whereKey("interestedGender", equalTo: interestedGender)
            }
            var ignoredUsers: [String] = []
            if let acceptedUsers = PFUser.current()?["accepted"] as? [String] {
                ignoredUsers += acceptedUsers
            }
            if let rejectedUsers = PFUser.current()?["rejected"] as? [String] {
                ignoredUsers += rejectedUsers
            }
            query.whereKey("objectId", notContainedIn: ignoredUsers)
            if let geoPoint = PFUser.current()?["location"] as? PFGeoPoint {
                query.whereKey("location", withinGeoBoxFromSouthwest: PFGeoPoint(latitude: geoPoint.latitude - 1, longitude: geoPoint.longitude - 1), toNortheast: PFGeoPoint(latitude: geoPoint.latitude + 1, longitude: geoPoint.longitude + 1))
            }
            if let currentUserId = PFUser.current()?.objectId {
                query.whereKey("objectId", notEqualTo: currentUserId)
            }
            query.limit = 1
            query.findObjectsInBackground { (objects, error) in
                if let users = objects {
                    for object in users {
                        if let user = object as? PFUser {
                            if let imageFile = user["photo"] as? PFFile {
                                imageFile.getDataInBackground(block: { (data, error) in
                                    if let imageData = data {
                                        self.matchImageView.image = UIImage(data: imageData)
                                        if let objectID = object.objectId{
                                            self.displayUserID = objectID
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

