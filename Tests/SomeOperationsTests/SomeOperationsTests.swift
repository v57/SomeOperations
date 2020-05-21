import XCTest
@testable import SomeOperations

final class SomeOperationsTests: XCTestCase {
  func testSyncOperation() {
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
  func testSyncOperations() {
    var result = 0
    let operations = SomeOperations()
    operations.add(.run {
      result = 1
    })
    XCTAssertEqual(result, 0)
    operations.add(.run {
      result = 2
    })
    XCTAssertEqual(result, 0)
    operations.add(.run {
      result = 3
    })
    XCTAssertEqual(result, 0)
    operations.run { status, action in
      XCTAssertEqual(status, .done)
      XCTAssertEqual(action, .next)
    }
    XCTAssertEqual(result, 3)
  }
  func testAsyncOperation() {
    var result = 0
    let semaphone = DispatchSemaphore(value: 0)
    let operation = SomeOperation.async(on: "testAsyncOperation".queue) {
      result = 1
      semaphone.signal()
    }
    XCTAssertEqual(result, 0)
    operation.run { status, action in
      XCTAssertEqual(status, .done)
      XCTAssertEqual(action, .next)
    }
    semaphone.wait()
    XCTAssertEqual(result, 1)
  }
  
  static var allTests = [
    ("testSyncOperation", testSyncOperation),
    ("testSyncOperations", testSyncOperations),
    ("testAsyncOperation", testAsyncOperation),
  ]
}

extension String {
  var queue: DispatchQueue {
    DispatchQueue(label: self)
  }
}
