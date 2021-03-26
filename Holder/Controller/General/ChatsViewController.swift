//
//  ChatsViewController.swift
//  Holder
//
//  Created by Maxim Perehod on 13.11.2020.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import AudioToolbox

struct ChatCell {
    var uid: String?
    var name: String?
    var lastMessage: String?
    var userImage: UIImage?
}

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // uid поддержки
    var techSupport = ChatCell(uid: "ndSnmRRy45ONcydfdbWKPd8cI1d2", name: "Служба поддержки", lastMessage: "Если возникли вопросы - пишите", userImage: UIImage(named: "jo"))
    var chatUsers = [ChatCell]()

    
    @IBOutlet var tableView: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chatUsers.count
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
        return 20
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AudioServicesPlaySystemSound(1520)
        performSegue(withIdentifier: "chatSegue", sender: chatUsers[indexPath.section].uid)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatSegue" {
            if let vc = segue.destination as? MessangerViewController {
                vc.uidIChatWith = sender as? String
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatsCell") as! ChatsTableViewCell
        cell.roundView.layer.cornerRadius =  40
        cell.userProfileImage.layer.cornerRadius = cell.userProfileImage.frame.height / 2
        cell.userProfileImage.clipsToBounds = true
        cell.lastMessage.text = chatUsers[indexPath.section].lastMessage
        print(chatUsers[indexPath.section].name)
        cell.userName.text = chatUsers[indexPath.section].name
        cell.userProfileImage.image = chatUsers[indexPath.section].userImage
        
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatUsers.insert(techSupport, at: 0)
        
        overrideUserInterfaceStyle = .light
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        
        loadChats()
        
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("chats").removeAllObservers()
    }
    
    
    // MARK:- алгоритм загрузки переписок
    /* Загружаем все айдишники, которые хранятся в Chats пользователя и потом по каждому такому айдишнику отдельно грузим инфу о собеседнике и его фотку */
    func loadChats() {
        Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid).child("chats").queryOrderedByKey().observe(.childAdded, with: {
            snapshot in
            var post = ChatCell()
            post.uid = snapshot.key
            
            if let dict = snapshot.value as? [String: Any] {
                if let msg = dict[dict.keys.sorted().last ?? ""] as? [String: Any] {
                    post.lastMessage = msg["body"] as! String
                }
            }
            var flag = 0
            Database.database().reference().child("Users").child(post.uid!).child("info").observeSingleEvent(of: .value, with: { [self]
                snapshot in
                if let dict = snapshot.value as? [String: Any] {
                    if let name = dict["name"] as? String {
                        post.name = name
                        print(name)
                        Storage.storage().reference().child(post.uid! + ".png").getData(maxSize: 5*1024*1024, completion: {
                            (data, error) in
                            if error == nil {
                                if data == nil {
                                    post.userImage = UIImage(named: "jo")
                                } else {
                                    post.userImage = UIImage(data: data!)
                                    self.chatUsers.insert(post, at: 1)
                                    self.tableView.reloadData()
                                }
                            } else {
                                print(error?.localizedDescription)
                            }
                        })
                        
                    }
                 }
                
            })
            
        })
    }
    
}
