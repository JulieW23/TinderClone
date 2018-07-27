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

    @IBOutlet weak var swipeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //add gesture recognizer to swipe label
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        swipeLabel.addGestureRecognizer(gesture)
    }
    
    // respond when swipeLabel is dragged
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        let labelPoint = gestureRecognizer.translation(in: view)
        
        // make label move when dragged
        swipeLabel.center = CGPoint(x: view.bounds.width / 2 + labelPoint.x, y: view.bounds.height / 2 + labelPoint.y)
        // pretty rotating of label
        let xFromCenter = view.bounds.width / 2 - swipeLabel.center.x
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 300)
        // pretty shrinking of label
        let scale = min(100 / abs(xFromCenter), 1)
        var scaledAndRotated = rotation.scaledBy(x: scale, y: scale)
        swipeLabel.transform = scaledAndRotated
        
        // detect when dragged left/right a certain distance
        if gestureRecognizer.state == .ended {
            let threshold = CGFloat(150)
            if swipeLabel.center.x < (view.bounds.width / 2 - threshold) {
                print("Not interested")
            } else if swipeLabel.center.x > (view.bounds.width / 2 + threshold) {
                print("Interested")
            }
            rotation = CGAffineTransform(rotationAngle: 0)
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)
            swipeLabel.transform = scaledAndRotated
            swipeLabel.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

