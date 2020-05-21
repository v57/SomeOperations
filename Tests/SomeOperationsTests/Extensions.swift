//
//  File.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

import XCTest
import Foundation

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
