import Foundation

@propertyWrapper
public class ThreadSpecific<T> {
    
    var allocatedStorages = [Storage<T>]()
    let valueClosure : () -> T
    var key = pthread_key_t()
    var storageLock = pthread_rwlock_t()
    
    public init(wrappedValue: @autoclosure @escaping () -> T) {
        self.valueClosure = wrappedValue
        pthread_key_create(&key) {
            $0.deallocate()
        }
        pthread_rwlock_init(&storageLock, nil)
    }
    
    deinit {
        pthread_key_delete(key)
        pthread_rwlock_destroy(&storageLock)
        
        for storage in allocatedStorages {
            storage.erase()
        }
    }
    
    public var wrappedValue: T {
        get { return try! threadSpecificStorage.getValue() }
        set (value) { threadSpecificStorage.set(value: value)}
    }
    
    public func erase() {
        if (pthread_getspecific(key) == nil) {
            return
        }
        
        threadSpecificStorage.erase()
        pthread_setspecific(key, nil)      
    }
    
    private var threadSpecificStorage: Storage<T> {
         get {
             if let storagePointer = pthread_getspecific(key) {
                let typedPointer: UnsafeMutablePointer<Storage<T>> = storagePointer.assumingMemoryBound(to: Storage<T>.self)
                return typedPointer.pointee
             }
             
            let newStorage = allocateStorage()
            let typedPointer = UnsafeMutablePointer<Storage<T>>.allocate(capacity: 1)
            typedPointer.initialize(to: newStorage)
            let rawPointer: UnsafeRawPointer = UnsafeRawPointer(typedPointer)
            
            pthread_setspecific(key, rawPointer)
            return newStorage
         }
     }
    
    func allocateStorage() -> Storage<T> {
        let defaultValue = valueClosure()
        
        pthread_rwlock_wrlock(&storageLock)
        defer { pthread_rwlock_unlock(&storageLock) }

        let newStorage = Storage<T>(value: defaultValue)
        allocatedStorages.append(newStorage)
        
        return newStorage
    }
}
