//
//  PhoneACKViewController.swift
//  Holder
//
//  Created by Maxim Perehod on 13.11.2020.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import AudioToolbox

class PhoneACKViewController: UIViewController {

    @IBOutlet var otpField: UITextField!
    var number: String?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
    

    func verifyOTP() {
        
        guard let otpCode = otpField.text else { return }
        guard let verificationId = UserDefaults.standard.string(forKey: "verifyId") else { return }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: otpCode)
        
        Auth.auth().signInAndRetrieveData(with: credential) { [self] (success, error) in
            if error == nil {
                // успешная авторизация!
                User.currentUser.setUid(uid: Auth.auth().currentUser!.uid) // сохраняем uid в класс текущего пользователя
                print(User.currentUser.getuid())
                print(number)
                Database.database().reference().child("Users").child(User.currentUser.getuid()).child("info").child("number").setValue(number)
                AudioServicesPlaySystemSound(1520)
                self.performSegue(withIdentifier: "nameSegue", sender: nil)
            } else {
                print(error?.localizedDescription)
                let alert = UIAlertController(title: "О нет!", message: error?.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: ":(", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func optField(_ sender: UITextField) {
        if sender.text?.count ?? 0 == 6 {
            verifyOTP()
            sender.resignFirstResponder()
        }
    }
    
    
    @IBAction func tap(_ sender: Any) {
        otpField.resignFirstResponder()
    }
    
    
    
}
