//
//  File.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

import XCTest
import Foundation
@testable import SomeOperations

func XCTAssertErrorEqual(_ error: Error?, _ error2: Error, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
  if let error = error {
    XCTAssertEqual("\(error)", "\(error2)", message(), file: file, line: line)
  } else {
    XCTAssert(false, "Error not found", file: file, line: line)
  }
}

extension String {
  var queue: DispatchQueue {
    DispatchQueue(label: self)
  }
}

struct SyncQueue {
  let queue: Queue
  let semaphore: DispatchSemaphore
  func resume() {
    queue.resume()
    semaphore.wait()
  }
}
extension SomeOperation {
  func runWait(_ completion: @escaping QueueCompletion) -> SyncQueue {
    let semaphore = DispatchSemaphore(value: 0)
    var queue: Queue!
    queue = run { error in
      completion(error)
      semaphore.signal()
      queue = nil
    }
    return SyncQueue(queue: queue, semaphore: semaphore)
  }
}
