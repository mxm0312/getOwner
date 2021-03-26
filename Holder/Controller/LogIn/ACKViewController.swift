//
//  ACKViewController.swift
//  Holder
//
//  Created by Maxim Perehod on 11.02.2021.
//

import UIKit
import FirebaseAuth
import AudioToolbox

class ACKViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var codeField: UITextField!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        codeField.delegate = self
        overrideUserInterfaceStyle = .light
    }
    

    func next() {
        guard let otpCode = codeField.text else { return }
        guard let verificationId = UserDefaults.standard.string(forKey: "verifyId") else { return }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: otpCode)
        
        Auth.auth().signInAndRetrieveData(with: credential) { [self] (success, error) in
            if error == nil {
                // успешная авторизация!
                AudioServicesPlaySystemSound(1520)
                User.currentUser.setUid(uid: Auth.auth().currentUser!.uid) // сохраняем uid в класс текущего пользователя
                print(User.currentUser.getuid())
                let viewController: HomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "home") as! HomeViewController
                self.present(viewController, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "О нет!", message: error?.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: ":(", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func tap(_ sender: Any) {
        codeField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        codeField.resignFirstResponder()
        return true
    }
    
    @IBAction func otpField(_ sender: UITextField) {
        if sender.text?.count ?? 0 == 6 {
            next()
            sender.resignFirstResponder()
        }
    }
    
    
}
