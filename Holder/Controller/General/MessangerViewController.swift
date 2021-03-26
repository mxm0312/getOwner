//
//  MessangerViewController.swift
//  Holder
//
//  Created by Maxim Perehod on 13.11.2020.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import AudioToolbox

class MessangerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    

    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var carLabel: UILabel!
    @IBOutlet var subView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var messageField: UITextField!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var bottomConstraintForMessageView: NSLayoutConstraint!
    var keyBoardSize = 290
    
    var keyBoardShown = false
    var currentDate: String?
    var datesArray = [String]() // костыль для корректного отображения дат сверху над сообщениями
  
    
    var uidIChatWith: String?
    var messages = [Message]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        currentDate = formatter.string(from: date)
        
        
        messages.removeAll()
        guard uidIChatWith == nil else {
            
            Database.database().reference().child("Users").child(uidIChatWith!).child("info").observeSingleEvent(of: .value, with: {
                snapshot in
                if let dict = snapshot.value as? [String: Any] {
                    if let name = dict["name"] as? String {
                        self.nameLabel.text = name
                    }
                }
            })
            
            Storage.storage().reference().child(uidIChatWith! + ".png").getData(maxSize: 5*1024*1024, completion: {
                (data, error) in
                if error == nil {
                    guard let imageData = data else {
                        return
                    }
                    self.profileImage.image = UIImage(data: imageData)
                } else {
                    
                }
            })
           
            Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("chats").child(uidIChatWith!).observe(.childAdded, with: {
                snapshot in
                
                if let dict = snapshot.value as? [String: Any] {
                    var message = Message()
                    if let body = dict["body"] as? String {
                        message.body = body
                    }
                    if let myMessage = dict["myMessage"] as? String {
                        message.myMessage = myMessage
                    }
                    if let time = dict["time"] as? String {
                        message.time = time
                    }
                    if let date = dict["date"] as? String {
                        message.date = date
                    }
                    
                    self.messages.append(message)
                    self.tableView.rowHeight = UITableView.automaticDimension
                }
                self.tableView.reloadData()
                self.scrollToBottom()
            })
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.tableView.frame.origin.y = 0
    
        messageField.setLeftPaddingPoints(10)
        overrideUserInterfaceStyle = .light
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        messageField.layer.cornerRadius = messageField.frame.height / 2
        messageField.delegate = self
        subView.layer.cornerRadius = 20
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func sendButton(_ sender: Any) {
        
        AudioServicesPlaySystemSound(1519)
        
        var min = String(Calendar.current.component(.minute, from: Date()))
        if Int(min)! < 10 {
            min = "0" + String(Calendar.current.component(.minute, from: Date()))
        }
    
      
        let message: [String: String] = ["body": messageField.text!,
                                      "time": String(Calendar.current.component(.hour, from: Date())) + ":" + min,
                                      "myMessage": "true",
                                      "date": currentDate ?? ""]

        // MARK: - сохраняю сообщение себе
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("chats").child(uidIChatWith!).childByAutoId().setValue(message)
        
        let message2: [String: String] = ["body": messageField.text!,
                                       "time": String(Calendar.current.component(.hour, from: Date())) + ":" + min,
                                       "myMessage": "false",
                                       "date": currentDate ?? ""]
        
        // MARK: - сохраняю сообщение собеседнику
        Database.database().reference().child("Users").child(uidIChatWith!).child("chats").child(Auth.auth().currentUser!.uid).childByAutoId().setValue(message2)
        
        
        messageField.text = ""
        sendButton.isEnabled = false
        tableView.reloadData()
        
    }
    
    @IBAction func options(_ sender: Any) {
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    // описание ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatTableViewCell
        cell.messageLabel.text = messages[indexPath.section].body
        cell.timeLabel.text = messages[indexPath.section].time
        cell.messageLabel.layer.cornerRadius = 20
        cell.messageLabel.clipsToBounds = true
        
        
        if currentDate != messages[indexPath.section].date && datesArray.contains(messages[indexPath.section].date ?? "") == false {
            datesArray.append(messages[indexPath.section].date ?? "")
            cell.dateLabel.text = messages[indexPath.section].date
        }
        
        
        if messages[indexPath.section].myMessage == "true" {
           
            // если сообщения мои
          
            let newLeftConstraint = NSLayoutConstraint(
                     item: cell.leftConstraint.firstItem,
                     attribute: cell.leftConstraint.firstAttribute,
                     relatedBy: .greaterThanOrEqual,
                     toItem: cell.leftConstraint.secondItem,
                     attribute: cell.leftConstraint.secondAttribute,
                     multiplier: 1,
                     constant: 32
            )
            newLeftConstraint.priority = cell.leftConstraint.priority
            
            
            let newRightConstraint = NSLayoutConstraint(
                     item: cell.rightConstraint.firstItem,
                     attribute: cell.rightConstraint.firstAttribute,
                     relatedBy: .equal,
                     toItem: cell.rightConstraint.secondItem,
                     attribute: cell.rightConstraint.secondAttribute,
                     multiplier: 1,
                     constant: 16
            )
            newRightConstraint.priority = cell.rightConstraint.priority
        
            
            NSLayoutConstraint.deactivate([cell.leftConstraint])
            NSLayoutConstraint.activate([newLeftConstraint])
            NSLayoutConstraint.deactivate([cell.rightConstraint])
            NSLayoutConstraint.activate([newRightConstraint])
            
            cell.leftConstraint = newLeftConstraint
            cell.rightConstraint = newRightConstraint
          
            cell.messageLabel.textAlignment = .right
            cell.timeLabel.textAlignment = .right
            
            cell.messageLabel.backgroundColor = UIColor(hexString: "#202020")
            cell.messageLabel.textColor = UIColor(hexString: "#FFFFFF")
            cell.timeLabel.textColor = UIColor(hexString: "#FFFFFF")
            
           
        } else {

            // если сообщения не мои
            cell.messageLabel.textAlignment = .left
            cell.timeLabel.textAlignment = .left
            
            let newRightConstraint = NSLayoutConstraint(
                     item: cell.rightConstraint.firstItem,
                     attribute: cell.rightConstraint.firstAttribute,
                     relatedBy: .greaterThanOrEqual,
                     toItem: cell.rightConstraint.secondItem,
                     attribute: cell.rightConstraint.secondAttribute,
                     multiplier: 1,
                     constant: 32)
            newRightConstraint.priority = cell.rightConstraint.priority
            
            let newLeftConstraint = NSLayoutConstraint(
                     item: cell.leftConstraint.firstItem,
                     attribute: cell.leftConstraint.firstAttribute,
                     relatedBy: .equal,
                     toItem: cell.leftConstraint.secondItem,
                     attribute: cell.leftConstraint.secondAttribute,
                     multiplier: 1,
                     constant: 16)
            
            newLeftConstraint.priority = cell.leftConstraint.priority
            
            NSLayoutConstraint.deactivate([cell.leftConstraint])
            NSLayoutConstraint.activate([newLeftConstraint])
            NSLayoutConstraint.deactivate([cell.rightConstraint])
            NSLayoutConstraint.activate([newRightConstraint])
            
            
            cell.leftConstraint = newLeftConstraint
            cell.rightConstraint = newRightConstraint
            
            
            cell.messageLabel.backgroundColor = UIColor(hexString: "#FFFFFF")
            cell.messageLabel.textColor = UIColor(hexString: "#202020")
            cell.timeLabel.textColor = UIColor(hexString: "#202020")
           
        }
        return cell
    }
    
    
    
    // убрать клавиатуру
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            print(self.tableView.frame.origin.y)
            if messages.count >= 5 {
                if self.tableView.frame.origin.y == 80 {
                    self.bottomConstraintForMessageView.constant = CGFloat(keyBoardSize)
                    self.view.layoutIfNeeded()
                    scrollToBottom()
                    
                }
            } else {
                
                if keyBoardShown == false {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.bottomConstraintForMessageView.constant += CGFloat(self.keyBoardSize)
                        self.view.layoutIfNeeded()
                    })
                    keyBoardShown = true
                }
                
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if messages.count >= 5 {
                if self.tableView.frame.origin.y != 80 {
                    self.bottomConstraintForMessageView.constant = 0
                    self.view.layoutIfNeeded()
                    self.tableView.frame.origin.y = 80
                    
                }
            } else {
                
             
                UIView.animate(withDuration: 0.2, animations: {
                    self.bottomConstraintForMessageView.constant = 0
                    self.view.layoutIfNeeded()
                })
                
                keyBoardShown = false
               
            }

        }
    }
    
    // убрать клаву на ретёрн
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if bottomConstraintForMessageView.constant != 0 {
            bottomConstraintForMessageView.constant = 0
        }
        messageField.resignFirstResponder()
        return true
    }
    
    // проскролить переписку вниз
    func scrollToBottom() {
        // 1
           let bottomRow = IndexPath(row: 0,
                                     section: messages.count - 1)
                                  
           // 2
           self.tableView.scrollToRow(at: bottomRow,
                                      at: .bottom,
                                      animated: true)
    }
   
    
    // пока пользователь не набрал что-то  sendButton.isEnabled = false
    @IBAction func messageEditing(_ sender: UITextField) {
        if keyBoardShown == true {
            bottomConstraintForMessageView.constant = 290
        }
        
        while String(sender.text?.first ?? ")") == " " {
            sender.text?.removeFirst()
        }
        
        if sender.text == "" || sender.text == nil {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("yopta")
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("chats").child(uidIChatWith!).removeAllObservers()
    }
    
    func setupUI() {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
                case 1136: // айфоны пятые и SE
                    keyBoardSize = 200
                    break
                case 1920: // 7+ 6s+ 6+
                   break
                case 1334: // 6 6s 7 8
                    print("8 iphone")
                   
                    break
                case 2208:
                    keyBoardSize = 270
                    break
                case 2436: // X Xs 11 pro
                  keyBoardSize = 290
                    break
                case 1792: // iphone 11 Xr
                    keyBoardSize = 290
                    break
                
                default:
                    print("unknown")
            }
        }
    }
}

// MARK: - добавить отступы
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
