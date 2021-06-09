//
//  ProfileViewController.swift
//  Holder
//
//  Created by Maxim Perehod on 13.11.2020.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth


class ProfileViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var switchBUtton: UISwitch!
    @IBOutlet var firstCarNameLabel: UILabel!
    @IBOutlet var secondCarNameLabel: UILabel!
    @IBOutlet var secondCarCard: UIView!
    @IBOutlet var gosNumberLabel: UILabel!
    @IBOutlet var changeButton: UIButton!
    @IBOutlet var changeButton1: UIButton!
    @IBOutlet var colorLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var secondCarViewHeight: NSLayoutConstraint!
    
    // MARK: - Для первой карточки машины
    @IBOutlet var firstCarCard: UIView!
    @IBOutlet var firstCardHeight: NSLayoutConstraint!
    @IBOutlet var firstCarLabelConstraint: NSLayoutConstraint!
    @IBOutlet var numberField: UITextField!
    @IBOutlet var colorField: UIView!
    // MARK: - Для второй карточки машины
    @IBOutlet var secondCarNum: UITextField!
    @IBOutlet var colorLabel2: UILabel!
    @IBOutlet var colorView2: UIView!
    @IBOutlet var gosNum2: UILabel!
    @IBOutlet var seconCarLabelConstraint: NSLayoutConstraint!
    
    
    var multyplier = 0.85
    var firstCardOpened = false
    var secondCardOpened = false
    var numberOfCar = "one"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        overrideUserInterfaceStyle = .light
        
        // MARK: - закругления
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.clipsToBounds = true
        firstCarCard.roundTop(radius: 20)
        firstCarCard.clipsToBounds = true
        secondCarCard.roundTop(radius: 20)
        secondCarCard.clipsToBounds = true
        colorField.layer.cornerRadius = colorField.frame.height / 2
        colorField.clipsToBounds = true
        colorView2.layer.cornerRadius = colorView2.frame.height / 2
        colorView2.clipsToBounds = true
        
        
        // MARK: - тень
        secondCarCard.layer.shadowRadius = 5
        secondCarCard.layer.shadowOffset = .zero
        secondCarCard.layer.shadowOpacity = 0.1
        secondCarCard.layer.shadowColor = UIColor.black.cgColor
        secondCarCard.layer.shadowPath = UIBezierPath(rect: secondCarCard.bounds).cgPath
        secondCarCard.layer.masksToBounds = false
        
        firstCarCard.layer.shadowRadius = 5
        firstCarCard.layer.shadowOffset = .zero
        firstCarCard.layer.shadowOpacity = 0.1
        firstCarCard.layer.shadowColor = UIColor.black.cgColor
        firstCarCard.layer.shadowPath = UIBezierPath(rect: firstCarCard.bounds).cgPath
        firstCarCard.layer.masksToBounds = false
               
        
        let loader = Loader()
        let queue = DispatchQueue.global(qos: .utility)
        
        
        if let imageData = UserDefaults.standard.data(forKey: "userImageData") {
            print("opa")
            imageView.image = UIImage(data: imageData)
        } else {
            print("ne opa")
            Storage.storage().reference().child(User.currentUser.getuid() + ".png").getData(maxSize: 5*1024*1024, completion: { (data, error) in
                if error == nil {
                    if data == nil {
                        self.imageView.image = UIImage(named: "jo")
                    } else {
                        self.imageView.image = UIImage(data: data!)
                    }
                }
            })
        }
        
        
        // MARK: - загрузка информации о пользователе и его фотографии в отдельном потоке
        queue.async {
            User.currentUser = loader.loadUser(uid: Auth.auth().currentUser!.uid)
            DispatchQueue.main.async {
                self.nameLabel.text = User.currentUser.getName()
                self.numberLabel.text = User.currentUser.getNumber()
                
                if User.currentUser.getAvailableToCall() == true {
                    self.switchBUtton.isOn = true
                } else {
                    self.switchBUtton.isOn = false
                }
            }
           

            if User.currentUser.getNumberOfCars() == 0 {
                // нет машин
                self.firstCarCard.isUserInteractionEnabled = false
                self.secondCarCard.isUserInteractionEnabled = false
            }
            if User.currentUser.getNumberOfCars() == 1 {
               
                DispatchQueue.main.async {
                    self.firstCarCard.isUserInteractionEnabled = true
                    self.firstCarNameLabel.text = User.currentUser.getCarAtIndex(index: 0).getModel().uppercased()
                }
                
            }
            if User.currentUser.getNumberOfCars() == 2 {
                
                DispatchQueue.main.async {
                    self.secondCarCard.alpha = 1
                    self.firstCarCard.isUserInteractionEnabled = true
                    self.secondCarCard.isUserInteractionEnabled = true
                    self.firstCarNameLabel.text = User.currentUser.getCarAtIndex(index: 0).getModel().uppercased()
                    self.secondCarNameLabel.text = User.currentUser.getCarAtIndex(index: 1).getModel().uppercased()
                }
            }
            if User.currentUser.getNumberOfCars() == 3 {
                
            }
        }
    }
    
    @IBAction func tapOnFirstCar(_ sender: Any) {
        if firstCardOpened == false {
            numberOfCar = "one"
            firstCardOpened = true
            
            let fullNumber = User.currentUser.getCarAtIndex(index: 0).getNumber() // number + reion
            print(fullNumber)
            var lowerBound = String.Index(encodedOffset: 0)
            var upperBound = String.Index(encodedOffset: 5)
            let number = String(fullNumber[lowerBound...upperBound])
            print("HUY " + number)
            lowerBound = String.Index(encodedOffset: 6)
            upperBound = String.Index(encodedOffset: 8)
            let region = String(fullNumber[lowerBound...upperBound])
            print("HUY " + region)
            numberField.text = (number + " " + region).uppercased()
            
            
            colorField.backgroundColor = UIColor(hexString: User.currentUser.getCarAtIndex(index: 0).getColor())
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                
                self.gosNumberLabel.alpha = 1
                self.colorLabel.alpha = 1
                self.changeButton1.alpha = 1
                self.colorField.alpha = 1
                self.numberField.alpha = 1
                
                self.firstCardHeight.constant = 300
                let newConstraint = self.firstCarLabelConstraint.constraintWithMultiplier(CGFloat(self.multyplier))
                self.view.removeConstraint(self.firstCarLabelConstraint)
                self.view.addConstraint(newConstraint)
                self.firstCarLabelConstraint = newConstraint
                self.view.layoutIfNeeded()
            })
        } else {
            firstCardOpened = false
            firstCarNameLabel.text = User.currentUser.getCarAtIndex(index: 0).getModel()
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
                
//                self.firstCarCard.backgroundColor = UIColor(hexString: "#202020")
//                self.firstCarNameLabel.textColor = UIColor(hexString: "#FFFFFF")
//                self.numberField.textColor = UIColor(hexString: "#FFFFFF")
//                self.colorLabel.textColor = UIColor(hexString: "#FFFFFF")
//                self.gosNumberLabel.textColor = UIColor(hexString: "#FFFFFF")
                //self.changeButton.titleLabel?.textColor = UIColor(hexString: "#FFFFFF")
                
                self.gosNumberLabel.alpha = 0
                self.colorLabel.alpha = 0
                self.changeButton1.alpha = 0
                self.colorField.alpha = 0
                
                self.firstCardHeight.constant = 118
                let newConstraint = self.firstCarLabelConstraint.constraintWithMultiplier(1)
                self.view.removeConstraint(self.firstCarLabelConstraint)
                self.view.addConstraint(newConstraint)
                self.firstCarLabelConstraint = newConstraint
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
    @IBAction func tapOnSecondCard(_ sender: Any) {

        if secondCardOpened == false {
            
                numberOfCar = "two"
                secondCarNameLabel.text = User.currentUser.getCarAtIndex(index: 1).getModel().uppercased()
                let fullNumber = User.currentUser.getCarAtIndex(index: 1).getNumber()
            
                var lowerBound = String.Index(encodedOffset: 0)
                var upperBound = String.Index(encodedOffset: 5)
                let number = String(fullNumber[lowerBound...upperBound])
                
                lowerBound = String.Index(encodedOffset: 6)
                upperBound = String.Index(encodedOffset: 8)
                let reion = String(fullNumber[lowerBound...upperBound])
                
            secondCarNum.text = (number + " " + reion).uppercased()
            
                colorView2.backgroundColor = UIColor(hexString: User.currentUser.getCarAtIndex(index: 1).getColor())
                UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
                   
                self.firstCardHeight.constant = 0
                self.gosNum2.alpha = 1
                self.colorLabel2.alpha = 1
                self.changeButton.alpha = 1
                self.colorView2.alpha = 1
                self.secondCarNum.alpha = 1
                    
                self.secondCarViewHeight.constant = 300
                    let newConstraint = self.seconCarLabelConstraint.constraintWithMultiplier(CGFloat(self.multyplier))
                self.view.removeConstraint(self.seconCarLabelConstraint)
                self.view.addConstraint(newConstraint)
                self.seconCarLabelConstraint = newConstraint
                self.view.layoutIfNeeded()
            })
            secondCardOpened = true
            
        } else {
            secondCardOpened = false
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: {
               
            self.firstCardHeight.constant = 118
            self.gosNum2.alpha = 0
            self.colorLabel2.alpha = 0
            self.changeButton.alpha = 0
            self.colorView2.alpha = 0
            self.secondCarNum.alpha = 0
                
            self.secondCarViewHeight.constant = 215
            let newConstraint = self.seconCarLabelConstraint.constraintWithMultiplier(1)
            self.view.removeConstraint(self.seconCarLabelConstraint)
            self.view.addConstraint(newConstraint)
            self.seconCarLabelConstraint = newConstraint
            self.view.layoutIfNeeded()
        })
        }
    }
    
   
    @IBAction func switchButton(_ sender: Any) {
        if switchBUtton.isOn == true {
            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("info").child("availableToCall").setValue(true)
        } else {
            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("info").child("availableToCall").setValue(false)
        }
    }
    
    
    @IBAction func change(_ sender: Any) {
        let st = structForCarVC(uid: Auth.auth().currentUser!.uid, carNumber: numberOfCar, whereToGoAfter: "toProfile")
        performSegue(withIdentifier: "toCarFromProfile", sender: st)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCarFromProfile" {
            if let vc = segue.destination as? CarViewController {
                if let st = sender as? structForCarVC {
                    vc.userUID = st.uid
                    vc.carNumber = st.carNumber
                    vc.whereToGoAfter = st.whereToGoAfter
                }
            }
        }
    }
    
    
    func setupUI() {
        changeButton.layer.cornerRadius = changeButton.frame.height/2
        changeButton1.layer.cornerRadius = changeButton1.frame.height/2
        changeButton1.clipsToBounds = true
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                case 1136: // айфоны пятые и SE
                    multyplier = 0.75
                    break
                case 1920: // 7+ 6s+ 6+
                   break
                case 1334: // 6 6s 7 8
                    print("8 iphone")
                    multyplier = 0.8
                    break
                case 2208:
                    multyplier = 0.85
                    break
                case 2436: // X Xs 11 pro
                    multyplier = 0.85
                    break
                case 1792: // iphone 11 Xr
                    multyplier = 0.85
                    break
                
                default:
                    print("unknown")
            }
        }
    }
}


extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}



