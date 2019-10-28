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
}

public class Termometer {
    @ThreadSpecific
    var degrees: Int = 0
}
