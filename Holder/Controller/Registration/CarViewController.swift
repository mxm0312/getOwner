//
//  CarViewController.swift
//  Holder
//
//  Created by Maxim Perehod on 13.11.2020.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import AudioToolbox

class CarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet var cardView: UIView!
    @IBOutlet var numberOfCar: UITextField!
    @IBOutlet var markAndModel: UITextField!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var regionField: UITextField!
    
    var userUID: String? // грузит машину того, кого передали в данную епременнцю
    var carNumber: String? // номер машины которую меняют ("one" или "two")
    var whereToGoAfter: String?
    var carColor: String? // цвет тачки в хекс
    var selectedColorIndex: Int?
    
    let arrayOfColors = ["#000000", "#FFFFFF", "#A9A9A9", "#FF2600", "#FF9300", "#FFFB00", "#78FA4C", "#0433FF", "#00FDFF", "#9437FF", "#FF8AD8"] // сделать массив из хекс
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ColorViewCell
        cell.contentView.backgroundColor = UIColor(hexString: arrayOfColors[indexPath.row])
        cell.contentView.layer.cornerRadius = cell.contentView.frame.width / 2
        
        
        if selectedColorIndex == indexPath.row {

            if arrayOfColors[indexPath.row] != "#FFFFFF" {
                cell.contentView.layer.borderColor = UIColor.white.cgColor
                cell.contentView.layer.borderWidth = 4
                
                print(indexPath.row)
            } else {
                print(indexPath.row)
                cell.contentView.layer.borderColor = UIColor.black.cgColor
                cell.contentView.layer.borderWidth = 4
            }
        } else {
            cell.contentView.layer.borderWidth = 0
        }
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        carColor = arrayOfColors[indexPath.row]
        AudioServicesPlaySystemSound(1521)
        if selectedColorIndex == indexPath.row {
            selectedColorIndex = -1
        } else {
            selectedColorIndex = indexPath.row
            collectionView.reloadData()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        numberOfCar.autocapitalizationType = .allCharacters
        regionField.delegate = self
        numberOfCar.delegate = self
        markAndModel.delegate = self
        
        if whereToGoAfter == "toProfile" && carNumber != nil {
            view.backgroundColor = UIColor.clear
            self.numberOfCar.placeholder = nil
            self.regionField.placeholder = nil
            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("cars").child(carNumber!).observeSingleEvent(of: .value, with: { [self] snapshot in
                
                if let dict = snapshot.value as? [String: Any] {
                    
                    if let model = dict["model"] as? String {
                        self.markAndModel.text = model
                    }
                    if let number = dict["number"] as? String {
                        var lowerBound = String.Index(encodedOffset: 0)
                        var upperBound = String.Index(encodedOffset: 5)
                        self.numberOfCar.text = String(number[lowerBound...upperBound]).uppercased()
                        lowerBound = String.Index(encodedOffset: 6)
                        upperBound = String.Index(encodedOffset: 8)
                        self.regionField.text = String(number[lowerBound...upperBound])
                    }
                    if let color = dict["color"] as? String {
                        self.selectedColorIndex = self.arrayOfColors.firstIndex(of: color)
                        carColor = self.arrayOfColors[selectedColorIndex ?? 0]
                        collectionView.reloadData()
                    }
                }
            })
        }
        
        
        Database.database().reference().child("Users").observe(.value, with: { snapshot in
            userCount = Int(snapshot.childrenCount)
        })
        
        User.currentUser.setUid(uid: Auth.auth().currentUser!.uid)
                
        cardView.roundTop(radius: 30)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    

    @IBAction func saveButton(_ sender: Any) {
        
        if carColor != nil && numberOfCar.text != "" && markAndModel.text != "" && userUID != nil && carNumber != nil && whereToGoAfter != nil && regionField.text != "" && numberOfCar.text?.count == 6 && regionField.text?.count == 3 {
            
            AudioServicesPlaySystemSound(1520)
            
            let newCar = Car(model: markAndModel.text!, number: numberOfCar.text!, color: carColor!)
            
            User.currentUser.addCar(car: newCar)
            
            let post: [String: String] = ["number": (numberOfCar.text! + regionField.text!).uppercased(),
                                          "model": markAndModel.text!,
                                          "color": carColor!]
            searchNumber(number: numberOfCar.text!)
        
            
            
            DispatchQueue.global(qos: .utility).async {
                
                // ВАЖНО! тут индекс 0, но он должен быть произвольным эта часть кода работает только дл 1 машины //
                
                
                if numberAlreadyExist(number: post["number"]!) == true && post["number"]! != User.currentUser.getCarAtIndex(index: 0).getNumber() {
                    
                    let alert = UIAlertController(title: "Упс...", message: "Этот номер уже занят, если кто-то другой зарегестрировался с вашим номером напишите об этой в тех поддержку", preferredStyle: .alert)
                    let action = UIAlertAction(title: ":(", style: .default, handler: nil)
                    alert.addAction(action)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
        
                    // загружаю машину в атрибуты пользователя
                    Database.database().reference().child("Users").child(self.userUID!).child("cars").child(self.carNumber!).setValue(post)
                    DispatchQueue.main.async {
                        if self.whereToGoAfter == "toHome" {
                            let viewController: HomeViewController = self.storyboard?.instantiateViewController(withIdentifier: "home") as! HomeViewController
                            self.present(viewController, animated: true, completion: nil)
                        } else {
                            let viewController: ProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "profile") as! ProfileViewController
                            self.present(viewController, animated: true, completion: nil)
                        }
                        
                    }
                    
                }
            }
            
        }
    }
    
    
    // MARK: - изменение текста в поле номера
        @IBAction func numberField(_ sender: UITextField) {
            
            sender.placeholder = nil
            regionField.placeholder = nil
            
            if sender.text?.count == 5 || sender.text?.count == 6 || sender.text?.count == 0 || sender.text?.count == 4{
                sender.keyboardType = .asciiCapable
                sender.reloadInputViews()
            } else {
                sender.keyboardType = .numberPad
                sender.reloadInputViews()
            }
            
            if sender.text == "" {
                sender.placeholder = "X000XX"
                regionField.placeholder = "000"
            }
            
            if sender.text?.count == 1 || sender.text?.count == 5 || sender.text?.count == 6 {
                
                if String(sender.text!.last!).toInt() != nil {
                    sender.text?.removeLast()
                }
            }
            
            if sender.text?.count == 2 || sender.text?.count == 3 || sender.text?.count == 4 {
                
                if String(sender.text!.last!).toInt() == nil {
                    sender.text?.removeLast()
                }
            }
            
            if sender.text?.count == 6 {
                regionField.becomeFirstResponder()
            }
        }
        // MARK: - изменение текста в поле региона
        @IBAction func regionField(_ sender: UITextField) {
            if sender.text?.count == 3 && numberOfCar.text?.count == 6   {
                textFieldShouldReturn(numberOfCar)
            }
            
            if sender.text?.count == 4 {
                sender.text?.removeLast()
            }
            if sender.text?.count ?? 0 >= 1 {
                if String(sender.text!.last!).toInt() == nil {
                    sender.text?.removeLast()
                }
            }
            
        }
        // MARK: - изменение текста в поле модели
        @IBAction func modelField(_ sender: UITextField) {
            if sender.text?.count == 16 {
                sender.text?.removeLast()
            }
        }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        numberOfCar.resignFirstResponder()
        regionField.resignFirstResponder()
        markAndModel.resignFirstResponder()
        return true
    }
    
    // MARK: - удаление обзёрверов
    override func viewDidDisappear(_ animated: Bool) {
        Database.database().reference().child("Users").removeAllObservers()
        Database.database().reference().child("OwnerlessNumbers").child(numberOfCar.text ?? "ХУЙ").removeAllObservers()
    }
    
}


// MARK: - Функция перенесения существующих отзывов к номеру в профиль нового пользователя
func searchNumber(number: String) {
 
    Database.database().reference().child("OwnerlessNumbers").child(number).observe(.childAdded, with: {
        snapshot in
       
        if let dict = snapshot.value as? [String: Any] {
            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("reviews").childByAutoId().setValue(dict)
            Database.database().reference().child("OwnerlessNumbers").child(number).child(snapshot.key).setValue(nil)
        }
    })
}

/* MARK: - Функция получает в качестве аргумента номер,
 который ввел пользователь и ппроверяет существует ли уже
 такой номер в базе данных. Если не существует, то возвращает false */

func numberAlreadyExist(number: String) -> Bool {
    var count = 0 // переменная должна быть равна числу пользователей для корректной работы функции
    var numbers = [String]()
    Database.database().reference().child("Users").observe(.childAdded, with: {
        snapshot in
       // print(snapshot.value)
        if let dict = snapshot.value as? [String: Any] { // полная библиотека пользователя
            if let carsDict = dict["cars"] as? [String: Any] { // библиотека машин
                
                if let firstCarDict = carsDict["one"] as? [String: Any] {
                    // библиотека первой машины
                    if let number = firstCarDict["number"] as? String { // номер первой машины
                        numbers.append(number)
                    }
                }
                if let secondCarDict = carsDict["two"] as? [String: Any] { // библиотека второй машины
                    
                    if let number = secondCarDict["number"] as? String { // номер второй машины
                        numbers.append(number)
                    }
                }
            }
        }
        count += 1
    })
    while userCount == nil || count != userCount {}
    
    if numbers.contains(number) {
        print("содержится")
        print(number)
        return true
    } else {
        print("не содержится")
        print(number)
        return false
    }
}


extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
extension UIView {

    func roundTop(radius:CGFloat = 5){
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }

    func roundBottom(radius:CGFloat = 5){
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
}
