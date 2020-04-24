import XCTest

import BuglessTests

var tests = [XCTestCaseEntry]()
tests += BuglessTests.allTests()
XCTMain(tests)
