//
// MARK: -сlass with user information
import Foundation

struct Review {
    var uid: String?
    var date: String?
    var body: String?
}

class User {
    
    static var currentUser = User(uid: "") /* текущий пользователь */
    private var uid: String?
    private var name: String?
    private var cars: [Car] = []
    private var availableToCall: Bool?
    private var number: String?
    var rewiews = [Review]()
    
    init(uid: String) {
        self.uid = uid
    }
    
    func addCar(car: Car) {
        self.cars.append(car)
    }
    
    // MARK: - setter
    func setName(name: String) {
        self.name = name
    }
    func setUid(uid: String) {
        self.uid = uid
    }
    func setavailableToCall(_ available: Bool) {
        self.availableToCall = available
    }
    func setNumber(number: String) {
        self.number = number
    }
    // MARK: - getter
    func getCarAtIndex(index: Int) -> Car {
        return self.cars[index]
    }
    func getNumberOfCars() -> Int {
        return self.cars.count
    }
    func getNumber() -> String {
        return self.number ?? ""
    }
    func getuid() -> String {
        guard let uid = self.uid else {return ""}
        return uid
    }
    func getName() -> String {
        guard let name = self.name else {return ""}
        return name
    }
    func getAvailableToCall() -> Bool {
        return self.availableToCall ?? false
    }
    
}
