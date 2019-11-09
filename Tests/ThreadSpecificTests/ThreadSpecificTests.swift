import XCTest
@testable import ThreadSpecific

final class ThreadSpecificTests: XCTestCase {
    func testGetsThreadSpecificDefaultValueFromASingleThread() {
        let termometer = Termometer()
        XCTAssertEqual(0, termometer.degrees)
    }
    
    func testSetsAndGetsANewValueForThreadSpecificPropertyFromASingleThread() {
        let termometer = Termometer()
        termometer.degrees = 17
        XCTAssertEqual(17, termometer.degrees)
    }
    
    func testDeallocatesOldValueWhenNewIsSet() {
        let valueOwner = ValueOwner()
        var oldValue: Value? = Value(42)
        let newValue = Value(43)
        weak var weakReferenceToOldValue = oldValue
        
        valueOwner.value = oldValue!
        oldValue = nil

        XCTAssertNotNil(weakReferenceToOldValue)
        valueOwner.value = newValue
        XCTAssertNil(weakReferenceToOldValue)
    }
    
    func testDeallocatesValueWhenOwnerIsDeallocated() {
        var valueOwner: ValueOwner? = ValueOwner()
        var value: Value? = Value(42)
        weak var weakReferenceToValue = value
        
        valueOwner!.value = value!
        value = nil

        XCTAssertNotNil(weakReferenceToValue)
        valueOwner = nil
        XCTAssertNil(weakReferenceToValue)
    }
    
    func testDeallocatesValueAfterItWasErrased() {
        let valueOwner = ValueOwner()
        var value: Value? = Value(42)
        weak var weakReferenceToValue = value
        
        valueOwner.value = value!
        value = nil

        XCTAssertNotNil(weakReferenceToValue)
        valueOwner.eraseValue()
        XCTAssertNil(weakReferenceToValue)
    }
}

public class Termometer {
    @ThreadSpecific
    var degrees: Int = 0
}

public class ValueOwner {
    @ThreadSpecific
    var value = Value(43)
    
    func eraseValue() {
        _value.erase()
    }
}

public class Value {
    let integer: Int
    
    init(_ integer: Int) {
        self.integer = integer
    }
}
