import XCTest
@testable import SomeOperations

final class SomeOperationsTests: XCTestCase {
  func testSingleSyncOperation() {
    var result = 0
    let operation = SomeOperation.run {
      result = 1
    }
    XCTAssertEqual(result, 0)
    operation.run { status, action in
      XCTAssertEqual(status, .done)
      XCTAssertEqual(action, .next)
    }
    XCTAssertEqual(result, 1)
  }
  
  static var allTests = [
    ("testSingleSyncOperation", testSingleSyncOperation),
  ]
}
