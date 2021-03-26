//
//  HomeViewController.swift
//  Holder
//
//  Created by Maxim Perehod on 13.11.2020.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import AudioToolbox


// идентификатор приложения: ca-app-pub-7347676770854701~7836831022
// идентификатор рекламного блока: ca-app-pub-7347676770854701/2201360960


var userYouLookingFor = User(uid: "") // объект пользователя, которого мы ищем
var number: String?
var userCount: Int?


class HomeViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet var searchLabel: UILabel!
    @IBOutlet var noReviewsLabel: UILabel! // если нет отзывов, то есть он!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var whiteView: UIView!
    @IBOutlet var subView: UIView!
    @IBOutlet var numberField: UITextField!
    @IBOutlet var constraint: NSLayoutConstraint!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var reviewsLabel: UILabel!
    @IBOutlet var writeReviewButton: UIButton!
    @IBOutlet var callButton: UIButton!
    @IBOutlet var chatButton: UIButton!
    @IBOutlet var regField: UITextField!
    @IBOutlet var subViewHeight: NSLayoutConstraint!
    
    @IBOutlet var whiteViewHeight: NSLayoutConstraint!
    
    
    enum UITextAutocapitalizationType : Int {
    case None
    case Words
    case Sentences
    case AllCharacters
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        numberField.autocapitalizationType = .allCharacters
        
        print(Auth.auth().currentUser?.uid)
        overrideUserInterfaceStyle = .light
        print(Auth.auth().currentUser?.uid)
        // MARK: - тень
        whiteView.layer.shadowRadius = 5
        whiteView.layer.shadowOffset = .zero
        whiteView.layer.shadowOpacity = 0.05
        whiteView.layer.shadowColor = UIColor.black.cgColor
        whiteView.layer.masksToBounds = false
        writeReviewButton.layer.cornerRadius = writeReviewButton.frame.size.height / 2
        callButton.layer.cornerRadius = callButton.frame.height/2
        chatButton.layer.cornerRadius = chatButton.frame.height/2
        
        
        image.layer.cornerRadius = image.frame.height/2
        image.clipsToBounds = true
        tableView.rowHeight = 160
        tableView.delegate = self
        tableView.dataSource = self
        numberField.delegate = self
        regField.delegate = self
        whiteView.layer.cornerRadius = 20
        subView.layer.cornerRadius = 20
        
       
        // мониторинг числа пользователей
        let task = Database.database().reference().child("Users").observe(.value, with: { snapshot in
            userCount = Int(snapshot.childrenCount)
        })
    }
    
    @IBAction func clearButton(_ sender: Any) {
        noReviewsLabel.isHidden = true
        numberField.text = ""
        regField.text = ""
        numberField.placeholder = "X000XX"
        regField.placeholder = "000"
        
        AudioServicesPlaySystemSound(1519)
        UIView.animate(withDuration: 0.5, animations: {
            self.subView.alpha = 0.0
            self.tableView.alpha = 0.0
            self.reviewsLabel.alpha = 0.0
            self.writeReviewButton.alpha = 0.0
        })
    }
    
    // MARK: - ПОИСК
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if numberField.text != "" && regField.text != "" {
            
            
            AudioServicesPlaySystemSound(1520)
            
            if userYouLookingFor.getuid() != "" {
                Database.database().reference().child("Users").child(userYouLookingFor.getuid()).child("reviews").removeAllObservers()
            }
           
            userYouLookingFor.rewiews.removeAll()
            userYouLookingFor.setName(name: "")
            userYouLookingFor.rewiews.removeAll()
            noReviewsLabel.isHidden = true
            
           
            numberField.resignFirstResponder()
            regField.resignFirstResponder()
            UIView.animate(withDuration: 0.5, animations: {
                self.subView.alpha = 1.0
                self.tableView.alpha = 1.0
                self.reviewsLabel.alpha = 1.0
                self.writeReviewButton.alpha = 1.0
            })
            // складываю номер и регион и перевожу их в верхний регистр. НОМЕРА ХРАНЯТСЯ В НИЖНЕМ РЕГИСТРЕ
            let numberFieldText = (numberField.text! + regField.text!).uppercased()
            
            let queue = DispatchQueue.global(qos: .utility)
            
            // MARK: - В другой нити начинается поиск пользователя и загрузка его атрибутов
            queue.async {
                let uidYouLookingFor = searchUser(searchNumber: numberFieldText)
                if uidYouLookingFor == "fuck" { /* Если пользователь не найден */
                    
                    userYouLookingFor.setUid(uid: uidYouLookingFor)
                    userYouLookingFor.rewiews.removeAll()
                    userYouLookingFor.setName(name: "")
                    
                    DispatchQueue.main.async {
                        
                        number = textField.text
                        self.subView.alpha = 0.0
                        self.tableView.alpha = 0.0
                        self.reviewsLabel.alpha = 0.0
                        self.writeReviewButton.alpha = 0.0
                        
                        let alert = UIAlertController(title: "О нет!", message: "Данного пользователя еще нет в системе, но вы можете ему написать отзыв и когда он зарегестрируеется с указанным Вами номером эти отзывы перейдут к нему 😈", preferredStyle: .alert)
                        let action1 = UIAlertAction(title: "Ясно!", style: .default, handler: nil)
                        let action2 = UIAlertAction(title: "Понятно!", style: .default, handler: nil)
                        alert.addAction(action1)
                        alert.addAction(action2)
                        /* переход в отзывы с уведомлением */
                        self.performSegue(withIdentifier: "review", sender: alert)
                    }
                    
                } else { /* Если пользователь найден */
                    userYouLookingFor.setUid(uid: uidYouLookingFor)
                    
                    let loader = Loader()
                    // загрузка имени и отзывов
                    let user = loader.loadUser(uid: userYouLookingFor.getuid()) // создаем юзера в которого загрузится вся информация по найденному uid
                    userYouLookingFor.setName(name: user.getName()) // присваеваем имя
                    userYouLookingFor.setavailableToCall(user.getAvailableToCall()) // присваеваем флаг
                    userYouLookingFor.setNumber(number: user.getNumber() ?? "") // номер телефона
                    let name = userYouLookingFor.getName()
                    loader.loadReviews(user: userYouLookingFor, tableView: self.tableView) // грузим отзывы
                    if userYouLookingFor.rewiews.count == 0 {
                        DispatchQueue.main.async {
                            self.noReviewsLabel.isHidden = false
                            self.tableView.reloadData()
                        }
                    }

                    // загрузка фотокарточки пользователя
                    Storage.storage().reference().child(userYouLookingFor.getuid()+".png").getData(maxSize: 5*1024*1024, completion: { (data, error) in
                            if error == nil {
                                self.image.image = UIImage(data: data!)
                            }
                                        
                        })
                                    
                        DispatchQueue.main.async {
                        self.nameLabel.text = name
                    }
                }
            }
            
        } else {
            numberField.resignFirstResponder()
            regField.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: - TableView stuff
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 1
     }
     func numberOfSections(in tableView: UITableView) -> Int {
         return userYouLookingFor.rewiews.count
     }
     
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         let headerView = UIView()
         headerView.backgroundColor = UIColor.clear
         return headerView
     }
     
     // Set the spacing between sections
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 20
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell") as! TableViewCell
        // cell.nameLabel.text = userYouLookingFor.rewiews[indexPath.row].name
         cell.roundView.layer.cornerRadius = 20
         cell.body.text = userYouLookingFor.rewiews[indexPath.section].body
         cell.dateLabel.text = userYouLookingFor.rewiews[indexPath.section].date
       
         
         guard let uid = userYouLookingFor.rewiews[indexPath.section].uid else {
             cell.nameLabel.text = "no name"
             return cell
         }
         Database.database().reference().child("Users").child(userYouLookingFor.rewiews[indexPath.section].uid!).child("info").observeSingleEvent(of: .value, with: { snapshot in
             if let dict = snapshot.value as? [String: Any] {
                 if let name = dict["name"] as? String {
                     cell.nameLabel.text = name
                 }
             }
         })
         
         Storage.storage().reference().child(userYouLookingFor.rewiews[indexPath.section].uid!+".png").getData(maxSize: 5*1024*1024, completion: { (data, error) in
             if error == nil {
                 cell.profileImage.image = UIImage(data: data!)
             } else {
                 print(error?.localizedDescription)
             }
         })
         return cell
     }
    
    
    // MARK: - подготавливает страницу отзыва
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "review" {
            if let vc = segue.destination as? ReviewViewController {
                AudioServicesPlaySystemSound(1519)
                noReviewsLabel.isHidden = true
                let alert = sender as? UIAlertController
                vc.noUserFoundAlert = alert
                
            }
        }
        
        if segue.identifier == "toChatFromHome" {
            if let vc = segue.destination as? MessangerViewController {
                vc.uidIChatWith = sender as? String
            }
        }
    }
    
    @IBAction func callMeMaybe(_ sender: Any) {
        print(userYouLookingFor.getNumber())
        if userYouLookingFor.getNumber() == "" {
            
            let alert = UIAlertController(title: "Упс", message: "Информация о телефоне пользователя еще не загрузилась!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            if userYouLookingFor.getAvailableToCall() == true {
                if let url = URL(string: "tel://\(userYouLookingFor.getNumber())") {
                     UIApplication.shared.openURL(url)
                     AudioServicesPlaySystemSound(1520)
                }
            } else {
                let alert = UIAlertController(title: "Упс", message: "Вы не можете позвонить пользователю ввиду его настроек конфиденциальности, но вы можете написать ему в чате!", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ок", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func chat(_ sender: Any) {
        
            AudioServicesPlaySystemSound(1520)
            if userYouLookingFor.getuid() == nil || userYouLookingFor.getuid() == "" {
                let alert = UIAlertController(title: "Хм", message: "Странно, что-то идёт не так. Попробуйте еще раз нажать, по идее все должно работать, так что хз", preferredStyle: .alert)
                let action = UIAlertAction(title: "че? ну ок", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
                performSegue(withIdentifier: "toChatFromHome", sender: userYouLookingFor.getuid())
            }
    }
    
    @IBAction func numberField(_ sender: UITextField) {
        sender.placeholder = nil
        regField.placeholder = nil
        
        sender.text = sender.text?.uppercased()
        
        if sender.text?.count == 5 || sender.text?.count == 6 || sender.text?.count == 0 || sender.text?.count == 4 {
            sender.keyboardType = .asciiCapable
            sender.reloadInputViews()
        } else {
            sender.keyboardType = .numberPad
            sender.reloadInputViews()
        }
        
        if sender.text == "" {
            sender.placeholder = "X000XX"
            regField.placeholder = "000"
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
            regField.becomeFirstResponder()
        }
    }
    
    @IBAction func regField(_ sender: UITextView) {
        
        if sender.text.count == 3 && numberField.text?.count == 6   {
            textFieldShouldReturn(numberField)
        }
        
        if sender.text.count == 4 {
            sender.text.removeLast()
        }
        if sender.text.count >= 1 {
            if String(sender.text!.last!).toInt() == nil {
                sender.text?.removeLast()
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Database.database().reference().child("Users").removeAllObservers()
        if userYouLookingFor.getuid() != "" {
            Database.database().reference().child("Users").child(userYouLookingFor.getuid()).child("reviews").removeAllObservers()
        }
        
        
    }
    
    
    func setupUI() {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                case 1136: // айфоны пятые и SE
                    whiteViewHeight.constant = 150
                    numberField.font = numberField.font?.withSize(40)
                    regField.font = regField.font?.withSize(15)
                    reviewsLabel.font = reviewsLabel.font.withSize(15)
                    searchLabel.font = searchLabel.font.withSize(15)
                    break
                case 1920: // 7+ 6s+ 6+ 8+
                    subViewHeight.constant = 200
                    subView.layoutIfNeeded()
                   break
                case 1334: // 6 6s 7 8
                    subViewHeight.constant = 200
                    subView.layoutIfNeeded()
                    break
                case 2208:
                    subViewHeight.constant = 200
                    subView.layoutIfNeeded()
                    break
                case 2436: // X Xs 11 pro
                  
                    break
                case 1792: // iphone 11 Xr
                    
                    break
                
                default:
                    print("unknown")
            }
        }
    }
}
    

 // MARK: - ищет пользовователя, чья машина обладает таким номером, по завершении возвращает uid
func searchUser(searchNumber: String) -> String {
    
    var flag = 0
    var count = 0
    var uid: String?
    
    Database.database().reference().child("Users").observe(.childAdded, with: {
        snapshot in
        
        if let dict = snapshot.value as? [String: Any] {
            if let carsDict = dict["cars"] as? [String: Any] {
                
                if let currentCarDict1 = carsDict["one"] as? [String: Any] {
                    if let number = currentCarDict1["number"] as? String {
                        if number == searchNumber {
                            uid = snapshot.key
                            flag = 1
                        }
                    }
                }
                
                if let currentCarDict2 = carsDict["two"] as? [String: Any] {
                    if let number = currentCarDict2["number"] as? String {
                        if number == searchNumber {
                            uid = snapshot.key
                            flag = 1
                        }
                    }
                }
                
                if let currentCarDict3 = carsDict["three"] as? [String: Any] {
                    if let number = currentCarDict3["number"] as? String {
                        if number == searchNumber {
                            uid = snapshot.key
                            flag = 1
                        }
                    }
                }
                
            }
        }
        count += 1
    })
    
    while true {
        if count == userCount {
            if flag == 1 {
                break
            } else {
                uid = "fuck"
                break
            }
        }
    }
    return uid!

}

extension String {
    func toInt() -> Int? {
        return Int(self)
    }
}
