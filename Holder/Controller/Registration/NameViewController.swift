//
//  nameViewController.swift
//  Holder
//
//  Created by Maxim Perehod on 13.11.2020.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import AudioToolbox

class NameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var nextButtonHeight: NSLayoutConstraint!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        overrideUserInterfaceStyle = .light
        nameField.delegate = self
        nextButton.layer.cornerRadius = nextButtonHeight.constant/2
        nextButton.isEnabled = false

    }
    
    @IBAction func nextButton(_ sender: Any) {
        
        if nameField.text == "" {
            
        } else {
            UserDefaults.standard.setValue(nameField.text, forKey: "userName")
            Database.database().reference().child("Users").child(User.currentUser.getuid()).child("info").child("name").setValue(nameField.text)
            AudioServicesPlaySystemSound(1520)
            User.currentUser.setName(name: nameField.text!)
            performSegue(withIdentifier: "imageSegue", sender: nil)
        }
        
//        let alert = UIAlertController(title: "Внимание", message: "имя поменять потом нельзя", preferredStyle: .alert)
//        let action = UIAlertAction(title: "ok", style: .default, handler: nil)
//        alert.addAction(action)
//        self.present(alert, animated: true, completion: nil)
//
        
    }
    
    @IBAction func tap(_ sender: Any) {
        nameField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameField.resignFirstResponder()
    }
    
    
    @IBAction func nameField(_ sender: Any) {
        if nameField.text?.count ?? 0 >= 3 {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor(hexString: "#202020")
        }
    }
    
    func setupUI() {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                case 1136: // айфоны пятые и SE
                    self.nextButtonHeight.constant = 45
                    break
                default:
                    print("unknown")
            }
        }
    }
    
}
