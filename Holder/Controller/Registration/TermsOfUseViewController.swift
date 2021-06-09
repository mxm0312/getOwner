//
//  TermsOfUseViewController.swift
//  Holder
//
//  Created by Maxim Perehod on 13.11.2020.
//

import UIKit

class TermsOfUseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light

       
    }
    
    @IBAction func submit(_ sender: Any) {
        termsAccepted = true
        dismiss(animated: true, completion: nil)
    }
    

}
