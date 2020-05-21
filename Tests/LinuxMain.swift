import XCTest

import SomeOperationsTests

var tests = [XCTestCaseEntry]()
tests += SomeOperationsTests.allTests()
XCTMain(tests)
