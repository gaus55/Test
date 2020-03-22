//
//  BaseViewController.swift
//  FintooTest
//
//  Created by Ghous Ansari on 10/03/20.
//  Copyright © 2020 Ghous Ansari. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, UIGestureRecognizerDelegate{
    
    //MARK:- Declaring variable
    let gestureTapOutside = UITapGestureRecognizer()
    
    //MARK:- view cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This will hide/unhide keyboard
        gestureTapOutside.addTarget(self, action: #selector(hideKeyboardOnTapOutside))
        gestureTapOutside.delegate = self
        self.view.addGestureRecognizer(gestureTapOutside)
        gestureTapOutside.cancelsTouchesInView = false
        // Do any additional setup after loading the view.
    }
    
    //This will hide keyboard
    @objc func hideKeyboardOnTapOutside(){
        self.view.endEditing(true)
    }
    
}
