//
//  PhoneLoginViewController.swift
//  Holder
//
//  Created by Maxim Perehod on 11.02.2021.
//

import UIKit
import FirebaseAuth
import AudioToolbox

class PhoneLoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var numberField: UITextField!
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberField.delegate = self
        overrideUserInterfaceStyle = .light
        
        // Do any additional setup after loading the view.
    }
    
    func next() {
        guard let phoneNumber = numberField.text else { return }
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil, completion: { (verificationID, error) in
            if error == nil {
                // do stuff
                print(verificationID)
                guard let verifyId = verificationID else { return }
                UserDefaults.standard.setValue(verifyId, forKey: "verifyId")
                UserDefaults.standard.synchronize()
                print(phoneNumber)
                AudioServicesPlaySystemSound(1520)
                self.performSegue(withIdentifier: "otpSegueLogin", sender: phoneNumber)
                
            } else {
                print(error?.localizedDescription)
            }
        })
        
    }
    
    
    @IBAction func tap(_ sender: Any) {
        numberField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        numberField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func numField(_ sender: Any) {
        if numberField.text?.count == 1 || numberField.text?.count == 2 {
            numberField.text = "+7"
        }
        
        if numberField.text?.count == 12 {
            next()
            numberField.resignFirstResponder()
            
        } else {
            
        }
    }
    

}
