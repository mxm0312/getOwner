//
//  ViewController.swift
//  Holder
//
//  Created by Maxim Perehod on 13.11.2020.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import AudioToolbox

var termsAccepted = false

class MainController: UIViewController {

    @IBOutlet var regButton: UIButton!
    @IBOutlet var regButtonHeight: NSLayoutConstraint!
    @IBOutlet var logButton: UIButton!
    @IBOutlet var logButtonHeigh: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        overrideUserInterfaceStyle = .light
        regButton.layer.cornerRadius = regButtonHeight.constant/2
        logButton.layer.cornerRadius = logButtonHeigh.constant/2
        logButton.layer.borderWidth = 2
        logButton.layer.borderColor = UIColor.black.cgColor
        if Auth.auth().currentUser != nil {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "home")
            vc!.modalPresentationStyle = .fullScreen
            self.present(vc!, animated: false, completion: nil)
        } else {
            regButton.alpha = 1
            logButton.alpha = 1
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "terms")
            self.present(vc!, animated: true, completion: nil)
        }
    }
    
    @IBAction func regButtton(_ sender: Any) {
        if termsAccepted == true {
            let viewController: PhoneViewController = self.storyboard?.instantiateViewController(withIdentifier: "reg") as! PhoneViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            viewDidLoad()
        }
        AudioServicesPlaySystemSound(1520)
    }
    
    @IBAction func logButton(_ sender: Any) {
        if termsAccepted == true {
            let viewController: PhoneLoginViewController = self.storyboard?.instantiateViewController(withIdentifier: "log") as! PhoneLoginViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        } else {
            viewDidLoad()
        }
        AudioServicesPlaySystemSound(1520)
    }
    
    func setupUI() {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                case 1136: // айфоны пятые и SE
                    self.regButtonHeight.constant = 45
                    self.logButtonHeigh.constant = 45
                    
                    break
                default:
                    print("unknown")
            }
        }
    }
    
}

