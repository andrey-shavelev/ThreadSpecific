import Foundation

@propertyWrapper
public class ThreadSpecific<T> {
    
    var allocatedStorages = [Storage<T>]()
    let valueClosure : () -> T
    var key = pthread_key_t()
    let storageLock = NSLock()
    
    public init(wrappedValue: @autoclosure @escaping () -> T) {
        self.valueClosure = wrappedValue
        pthread_key_create(&key) {
            $0.deallocate()
        }
    }
    
    deinit {
        pthread_key_delete(key)
    }
    
    public var wrappedValue: T {
        get { return threadSpecificStorage.getValue() }
        set (value) { threadSpecificStorage.setValue(value: value)}
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
        
        storageLock.lock()
        let newStorage = Storage<T>(value: defaultValue)
        allocatedStorages.append(newStorage)
        storageLock.unlock()
        
        return newStorage
    }
}
