//
//  PhoneViewController.swift
//  Holder
//
//  Created by Maxim Perehod on 13.11.2020.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import AudioToolbox


class PhoneViewController: UIViewController {
    
    @IBOutlet var phoneField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
    
    func confirm() {
        
        
        guard let phoneNumber = phoneField.text else { return }
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil, completion: { (verificationID, error) in
            if error == nil {
                // do stuff
                print(verificationID)
                guard let verifyId = verificationID else { return }
                UserDefaults.standard.setValue(verifyId, forKey: "verifyId")
                UserDefaults.standard.synchronize()
                print(phoneNumber)
                AudioServicesPlaySystemSound(1520)
                self.performSegue(withIdentifier: "otpSegue", sender: phoneNumber)
                
            } else {
                print(error?.localizedDescription)
                let alert = UIAlertController(title: "О нет!", message: error?.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: ":(", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "otpSegue" {
            if let vc = segue.destination as? PhoneACKViewController {
                let number = sender as? String
                vc.number = number
            }
        }
    }

    
    @IBAction func phoneFieldChanging(_ sender: Any) {
        
        if phoneField.text?.count == 1 || phoneField.text?.count == 2 {
            phoneField.text = "+7"
        }
        
        if phoneField.text?.count == 12 {
            phoneField.resignFirstResponder()
            confirm()
        } else {
            
        }
    }
    
    @IBAction func tap(_ sender: Any) {
        phoneField.resignFirstResponder()
    }
    
}
