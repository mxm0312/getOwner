//
//  ReviewViewController.swift
//  Holder
//
//  Created by Maxim Perehod on 26.01.2021.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
import AudioToolbox

class ReviewViewController: UIViewController, UITextFieldDelegate {

   
    @IBOutlet var textField: UITextField!
    var noUserFoundAlert: UIAlertController?
    var post = Review()
    
    override func viewWillAppear(_ animated: Bool) {
        guard noUserFoundAlert == nil else {
            self.present(noUserFoundAlert!, animated: true, completion: nil)
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        textField.delegate = self
    
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        while String(textField.text?.first ?? ")") == " " {
            textField.text?.removeFirst()
        }
        if textField.text == "" {
            self.textField.resignFirstResponder()
            // alert
            
        } else {
            
            if userYouLookingFor.getuid() == "fuck" {
                // отзыв прикрепляется к номеру
                self.textField.resignFirstResponder()
                post.body = textField.text
                post.uid = Auth.auth().currentUser?.uid
               
                let date = Date()
                let formatter = DateFormatter()
                
                formatter.dateFormat = "dd.MM.yyyy"
                let result = formatter.string(from: date)
                
                post.date = result
                
                let dict: [String: String?] = ["uid": post.uid,
                            "body": post.body,
                            "date": post.date]
                
                Database.database().reference().child("OwnerlessNumbers").child(number!).childByAutoId().setValue(dict)
                
                self.dismiss(animated: true, completion: nil)
                
            } else {
                self.textField.resignFirstResponder()
                post.body = textField.text
                post.uid = Auth.auth().currentUser?.uid
               
                let date = Date()
                let formatter = DateFormatter()
                
                formatter.dateFormat = "dd.MM.yyyy"
                let result = formatter.string(from: date)
                
                post.date = result
                
                let dict: [String: String?] = ["uid": post.uid,
                            "body": post.body,
                            "date": post.date]
                
                Database.database().reference().child("Users").child(userYouLookingFor.getuid()).child("reviews").childByAutoId().setValue(dict)
                AudioServicesPlaySystemSound(1520)
                self.dismiss(animated: true, completion: nil)
            }
           
            
        }
        
        return true
    }

}
