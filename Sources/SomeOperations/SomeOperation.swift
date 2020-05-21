//
//  SomeOperation.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

class SomeOperation {
  enum Status: Equatable {
    case done, failed(Error)
    static func ==(l: Status, r: Status) -> Bool {
      switch (l,r) {
      case (.done, .done):
        return true
      case let (.failed(error1), .failed(error2)):
        return "\(error1)" == "\(error2)"
      default:
        return false
      }
    }
  }
  enum Action {
    case next
  }
  enum State {
    case idle, running, completed
  }
  var state: State = .idle
  var queues = Set<Queue>()
  func run(completion: @escaping (Status, Action)->()) {
    completion(.done, .next)
  }
  class Queue: Hashable {
    var index = 0
    let operations: [SomeOperation]
    let completion: (Queue, Status, Action) -> ()
    init(operations: [SomeOperation], completion: @escaping (Queue, Status, Action) -> ()) {
      self.operations = operations
      self.completion = completion
    }
    func resume() {
      next()
    }
    func next() {
      guard index < operations.count else {
        done(status: .done, action: .next)
        return
      }
      operations[index].run(completion: process)
    }
    func process(status: Status, action: Action) {
      switch status {
      case .done:
        switch action {
        case .next:
          index += 1
          next()
        }
      case .failed:
        done(status: status, action: action)
      }
    }
    func done(status: Status, action: Action) {
      completion(self, status, action)
    }
    func hash(into hasher: inout Hasher) {
      ObjectIdentifier(self).hash(into: &hasher)
    }
    static func ==(l: Queue, r: Queue) -> Bool {
      return l === r
    }
  }
}
