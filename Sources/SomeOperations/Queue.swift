//
//  File.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

import Foundation

class SomeOperationQueue: Hashable {
  var index = 0
  let operations: [SomeOperation]
  let completion: (SomeOperationQueue, SomeOperation.Status, SomeOperation.Action) -> ()
  var state: SomeOperation.State = .idle
  var current: SomeOperation? {
    index < operations.count ? operations[index] : nil
  }
  init(operations: [SomeOperation], completion: @escaping (SomeOperationQueue, SomeOperation.Status, SomeOperation.Action) -> ()) {
    self.operations = operations
    self.completion = completion
  }
  func cancel() {
    state = .done(.cancelled)
    current?.cancel()
    done(status: .cancelled, action: .next)
  }
  func resume() {
    state = .running
    next()
  }
  func next() {
    guard index < operations.count else {
      done(status: .done, action: .next)
      return
    }
    guard state != .done(.cancelled) else { return }
    operations[index].run(completion: process)
  }
  func process(status: SomeOperation.Status, action: SomeOperation.Action) {
    guard state.isRunning else { return }
    switch status {
    case .done:
      switch action {
      case .next:
        index += 1
        next()
      }
    default:
      done(status: status, action: action)
    }
  }
  func done(status: SomeOperation.Status, action: SomeOperation.Action) {
    completion(self, status, action)
  }
  func hash(into hasher: inout Hasher) {
    ObjectIdentifier(self).hash(into: &hasher)
  }
  static func ==(l: SomeOperationQueue, r: SomeOperationQueue) -> Bool {
    return l === r
  }
}
