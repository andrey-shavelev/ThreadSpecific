//
//  Storage.swift
//  Created by Andrey Shavelev on 28/10/2019.
//

class Storage<T> {
    private var value: T
    
    init(value: T) {
        self.value = value
    }
    
    func setValue(value: T){
        self.value = value
    }
    
    func getValue() -> T { value }
}
