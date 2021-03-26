//
//  Car.swift
//  Holder
//
//  Created by Maxim Perehod on 25.11.2020.
//

// MARK: -сlass for user's car

class Car {
    
    private var model: String?
    private var number: String?
    private var color: String?
    
    init(model: String, number: String, color: String) {
        self.number = number
        self.color = color
        self.model = model
    }
    

    // MARK: - setters
    func setModel(model: String) {
        self.model = model
    }
    func setNumber(number: String) {
        self.number = number
    }
    func setColor(color: String) {
        self.color = color
    }
    // MARK: - getters
    func getModel() -> String {
        guard self.model != nil else {return ""}
        return self.model!
    }
    func getNumber() -> String {
        guard self.number != nil else {return ""}
        return self.number!
    }
    func getColor() -> String {
        guard self.color != nil else {return ""}
        return self.color!
    }
    
    
}
