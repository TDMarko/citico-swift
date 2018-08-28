//
//  UIViewController+Keyboard.swift
//  CiticoNotes
//
//  Created by Marks Timofejevs on 28/08/2018.
//  Copyright © 2018 Marks Timofejevs. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
