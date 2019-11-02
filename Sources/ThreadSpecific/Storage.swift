//
//  Storage.swift
//  Created by Andrey Shavelev on 28/10/2019.
//

class Storage<T> {
    private var value: T?
    
    init(value: T) {
        self.value = value
    }
    
    func erase(){
        self.value = nil
    }
    
    func getValue() throws -> T {
        guard let value = value else {
            throw ThreadSpecificStorageError.storageErased
        }
        
        return value
    }
    
    func set(value: T) { self.value = value }
}
