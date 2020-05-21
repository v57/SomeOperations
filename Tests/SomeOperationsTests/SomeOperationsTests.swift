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
    let queue = "testAsyncOperation".queue
    let operation = SomeOperation.async(on: queue) {
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
  func testAsyncOperations() {
    var result = 0
    let semaphone = DispatchSemaphore(value: 0)
    let queue = "testAsyncOperations".queue
    let operations = SomeOperations()
    operations.add(.async(on: queue) {
      result = 1
    })
    XCTAssertEqual(result, 0)
    operations.add(.async(on: queue) {
      result = 2
    })
    XCTAssertEqual(result, 0)
    operations.add(.async(on: queue) {
      result = 3
    })
    XCTAssertEqual(result, 0)
    operations.run { status, action in
      XCTAssertEqual(status, .done)
      XCTAssertEqual(action, .next)
      semaphone.signal()
    }
    semaphone.wait()
    XCTAssertEqual(result, 3)
  }
  func testAsyncRecursiveOperations() {
    var result = 0
    let semaphone = DispatchSemaphore(value: 0)
    let queue = "testAsyncRecursiveOperations".queue
    let operations = SomeOperations()
    operations.add(.async(on: queue) {
      result += 1
    })
    XCTAssertEqual(result, 0)
    operations.add(.async(on: queue) {
      result += 1
    })
    for _ in 0..<10 {
      let ops = SomeOperations()
      operations.add(.async(on: queue) {
        result += 1 // +10
      })
      operations.add(ops)
    }
    XCTAssertEqual(result, 0)
    operations.add(.async(on: queue) {
      result += 1
    })
    XCTAssertEqual(result, 0)
    operations.run { status, action in
      XCTAssertEqual(status, .done)
      XCTAssertEqual(action, .next)
      semaphone.signal()
    }
    semaphone.wait()
    XCTAssertEqual(result, 13)
  }
  enum FailedError: Error {
    case some
  }
  func testAsyncRecursiveFailedOperations() {
    var result = 0
    let semaphone = DispatchSemaphore(value: 0)
    let queue = "testAsyncRecursiveOperations".queue
    let operations = SomeOperations()
    operations.add(.async(on: queue) {
      result += 1
    })
    XCTAssertEqual(result, 0)
    operations.add(.async(on: queue) {
      result += 1
    })
    for _ in 0..<10 {
      let ops = SomeOperations()
      operations.add(.asyncWithResult(on: queue) {
        result += 1 // +10
        return (.failed(FailedError.some), .next)
      })
      operations.add(ops)
    }
    XCTAssertEqual(result, 0)
    operations.add(.async(on: queue) {
      result += 1
    })
    XCTAssertEqual(result, 0)
    operations.run { status, action in
      XCTAssertEqual(status, .failed(FailedError.some))
      XCTAssertEqual(action, .next)
      semaphone.signal()
    }
    semaphone.wait()
    XCTAssertEqual(result, 3)
  }
  
  static var allTests = [
    ("testSyncOperation", testSyncOperation),
    ("testSyncOperations", testSyncOperations),
    ("testAsyncOperation", testAsyncOperation),
    ("testAsyncRecursiveOperations", testAsyncRecursiveOperations),
    ("testAsyncRecursiveFailedOperations", testAsyncRecursiveFailedOperations),
  ]
}

extension String {
  var queue: DispatchQueue {
    DispatchQueue(label: self)
  }
}
