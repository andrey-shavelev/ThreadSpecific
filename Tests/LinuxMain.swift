import XCTest

import ThreadSpecificTests

var tests = [XCTestCaseEntry]()
tests += ThreadSpecificTests.allTests()
XCTMain(tests)
