//
//  SomeOperation.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

class SomeOperation {
  enum Status {
    case done, failed(Error), cancelled
  }
  enum Action {
    case next
  }
  enum State {
    case idle, running, done(Status)
  }
  var queues = Set<SomeOperationQueue>()
  func run(completion: @escaping (Status, Action)->()) {
    completion(.done, .next)
  }
  func cancel() {
    queues.forEach { $0.cancel() }
  }
}

extension SomeOperation.Status: Equatable {
  static func ==(l: SomeOperation.Status, r: SomeOperation.Status) -> Bool {
    switch (l,r) {
    case (.done, .done), (.cancelled, .cancelled):
      return true
    case let (.failed(error1), .failed(error2)):
      return "\(error1)" == "\(error2)"
    default:
      return false
    }
  }
}
extension SomeOperation.State: Equatable {
  static func ==(l: SomeOperation.State, r: SomeOperation.State) -> Bool {
    switch (l,r) {
    case (.idle, .idle), (.running, .running):
      return true
    case let (.done(status1), .done(status2)):
      return status1 == status2
    default:
      return false
    }
  }
  var isRunning: Bool {
    switch self {
    case .running:
      return true
    default:
      return false
    }
  }
  var isDone: Bool {
    switch self {
    case .done:
      return true
    default:
      return false
    }
  }
}
