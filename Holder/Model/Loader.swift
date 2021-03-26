//
//  loader.swift
//  Holder
//
//  Created by Maxim Perehod on 25.11.2020.
//
import FirebaseDatabase
import FirebaseStorage
// MARK: - сlass fork with firebase

class Loader {

    // заполняет объект пользователя
    func loadUser(uid: String) -> User {
        let user = User(uid: uid)
        var flag = 0
        
        Database.database().reference().child("Users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
               
                
                if let carDict = dict["cars"] as? [String: Any] { // гружу машины
                  
                    
                    if let firstCarDict = carDict["one"] as? [String: Any] { // добавляем первую машину
                        
                        var car = Car(model: "", number: "", color: "")
                        
                        if let color = firstCarDict["color"] as? String {
                            car.setColor(color: color)
                        }
                        if let model = firstCarDict["model"] as? String {
                            car.setModel(model: model)
                        }
                        if let number = firstCarDict["number"] as? String {
                            car.setNumber(number: number)
                        }
                       
                        user.addCar(car: car)
                        
                    }
                    if let secondCarDict = carDict["two"] as? [String: Any] { // добавляем вторую машину
                        
                        var car = Car(model: "", number: "", color: "")
                        
                        if let color = secondCarDict["color"] as? String {
                            car.setColor(color: color)
                        }
                        if let model = secondCarDict["model"] as? String {
                            car.setModel(model: model)
                        }
                        if let number = secondCarDict["number"] as? String {
                            car.setNumber(number: number)
                        }
                        user.addCar(car: car)
                    }
                    
                    if let thirdCarDict = carDict["three"] as? [String: Any] { // добавляем третью машину
                        
                        var car = Car(model: "", number: "", color: "")
                        
                        if let color = thirdCarDict["color"] as? String {
                            car.setColor(color: color)
                        }
                        if let model = thirdCarDict["model"] as? String {
                            car.setModel(model: model)
                        }
                        if let number = thirdCarDict["number"] as? String {
                            car.setNumber(number: number)
                        }
                        user.addCar(car: car)
                    }
                } else {
                    print("ЭЭЭМ")
                }
                
                if let infoDict = dict["info"] as? [String: Any] {
                    
                    if let name = infoDict["name"] as? String {
                        user.setName(name: name)
                    }
                    if let numberFlag = infoDict["availableToCall"] as? Bool {
                        user.setavailableToCall(numberFlag)
                    }
                    if let number = infoDict["number"] as? String {
                        user.setNumber(number: number)
                    }
                }
            }
            print("все грузанулось")
            print(user.getName(), user.getNumber(), user.getCarAtIndex(index: 0).getModel())
            flag = 1 // всё загрузилось
        })
        while flag == 0 {} // пока не загрузится пользователь функция ничего не возвращает
        
        return user
    }
    
  
    
    // загружает переписки пользователя
    func loadReviews(user: User, tableView: UITableView) {
        var flag = 0
        Database.database().reference().child("Users").child(user.getuid()).observeSingleEvent(of: .value, with: {
            snapshot in
            if snapshot.hasChild("reviews") == false {
                flag = 1
            }
        })
        Database.database().reference().child("Users").child(user.getuid()).child("reviews").observe(.childAdded, with: { snapshot in
            if let dict = snapshot.value as? [String: Any] {
                var post = Review()
                if let uid = dict["uid"] as? String {
                    post.uid = uid
                }
                if let date = dict["date"] as? String {
                    post.date = date
                }
                if let body = dict["body"] as? String {
                    post.body = body
                }
                user.rewiews.insert(post, at: user.rewiews.startIndex)
                
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
            
            flag = 1
        })
        while flag == 0 {} // аля семафор, чтобы функция не вернула ничего, пока не загрузится
        
    }
}



