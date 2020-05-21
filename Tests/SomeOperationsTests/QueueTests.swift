import XCTest
@testable import SomeOperations

final class QueueTests: XCTestCase {
  func testSyncOperation() {
    var result = 0
    let operation = Operation.run {
      result = 1
    }
    XCTAssertEqual(result, 0)
    let resultQueue = operation.run { error in
      XCTAssertNil(error)
    }
    resultQueue.resume()
    XCTAssertEqual(result, 1)
  }
  func testSyncOperations() {
    var result = 0
    let queue = Queue()
    queue.add(.run {
      result = 1
    })
    XCTAssertEqual(result, 0)
    queue.add(.run {
      result = 2
    })
    XCTAssertEqual(result, 0)
    queue.add(.run {
      result = 3
    })
    XCTAssertEqual(result, 0)
    let resultQueue = queue.run { error in
      XCTAssertNil(error)
    }
    resultQueue.resume()
    XCTAssertEqual(result, 3)
  }
  func testAsyncOperation() {
    var result = 0
    let semaphone = DispatchSemaphore(value: 0)
    let queue = "testAsyncOperation".queue
    let operation = Operation.async(on: queue) {
      result = 1
    }
    XCTAssertEqual(result, 0)
    let resultQueue = operation.run { error in
      XCTAssertNil(error)
      semaphone.signal()
    }
    resultQueue.resume()
    semaphone.wait()
    XCTAssertEqual(result, 1)
  }
  func testAsyncOperations() {
    var result = 0
    let semaphone = DispatchSemaphore(value: 0)
    let queue = "testAsyncOperations".queue
    let operations = Queue()
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
    let resultQueue = operations.run { error in
      XCTAssertNil(error)
      semaphone.signal()
    }
    resultQueue.resume()
    semaphone.wait()
    XCTAssertEqual(result, 3)
  }
  func testAsyncRecursiveOperations() {
    var result = 0
    let semaphone = DispatchSemaphore(value: 0)
    let queue = "testAsyncRecursiveOperations".queue
    let operations = Queue()
    operations.add(.async(on: queue) {
      result += 1
    })
    XCTAssertEqual(result, 0)
    operations.add(.async(on: queue) {
      result += 1
    })
    for _ in 0..<10 {
      let ops = Queue()
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
    let resultQueue = operations.run { error in
      XCTAssertNil(error)
      semaphone.signal()
    }
    resultQueue.resume()
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
    let operations = Queue()
    operations.add(.async(on: queue) {
      result += 1
    })
    XCTAssertEqual(result, 0)
    operations.add(.async(on: queue) {
      result += 1
    })
    for _ in 0..<10 {
      let ops = Queue()
      operations.add(.asyncWithResult(on: queue) { queue in
        result += 1 // +10
        queue.failed(error: FailedError.some)
      })
      operations.add(ops)
    }
    XCTAssertEqual(result, 0)
    operations.add(.async(on: queue) {
      result += 1
    })
    XCTAssertEqual(result, 0)
    let resultQueue = operations.run { error in
      XCTAssertErrorEqual(error, FailedError.some)
      semaphone.signal()
    }
    resultQueue.resume()
    semaphone.wait()
    XCTAssertEqual(result, 3)
  }
  func testAsyncRecursiveCancelledOperations() {
    var result = 0
    let semaphone = DispatchSemaphore(value: 0)
    let operationSemaphore = DispatchSemaphore(value: 0)
    let queue = "testAsyncRecursiveCancelledOperations".queue
    let operations = Queue()
    operations.add(.async(on: queue) {
      result += 1
    })
    XCTAssertEqual(result, 0)
    operations.add(.async(on: queue) {
      result += 1
    })
    for _ in 0..<10 {
      let ops = Queue()
      operations.add(.async(on: queue) {
        result += 1 // +10
        operationSemaphore.signal()
      })
      operations.add(.wait(1.0) {
        result += 1 // +10
      })
      operations.add(.asyncWithResult(on: queue) { queue in
        result += 1 // +10
        queue.failed(error: FailedError.some)
      })
      operations.add(ops)
    }
    XCTAssertEqual(result, 0)
    operations.add(.async(on: queue) {
      result += 1
    })
    XCTAssertEqual(result, 0)
    let resultQueue = operations.run { error in
      XCTAssertNil(error)
      semaphone.signal()
    }
    resultQueue.resume()
    operationSemaphore.wait()
    operations.cancel()
    semaphone.wait()
    XCTAssertEqual(result, 3)
  }
  
  static var allTests = [
    ("testSyncOperation", testSyncOperation),
    ("testSyncOperations", testSyncOperations),
    ("testAsyncOperation", testAsyncOperation),
    ("testAsyncRecursiveOperations", testAsyncRecursiveOperations),
    ("testAsyncRecursiveFailedOperations", testAsyncRecursiveFailedOperations),
    ("testAsyncRecursiveCancelledOperations", testAsyncRecursiveCancelledOperations),
  ]
}


func XCTAssertErrorEqual(_ error: Error?, _ error2: Error, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
  if let error = error {
    XCTAssertEqual("\(error)", "\(error2)", message(), file: file, line: line)
  } else {
    XCTAssert(false, "Error not found", file: file, line: line)
  }
}
