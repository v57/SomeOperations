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
  var queues = Set<Queue>()
  func run(completion: @escaping (Status, Action)->()) {
    completion(.done, .next)
  }
  func cancel() {
    queues.forEach { $0.cancel() }
  }
  class Queue: Hashable {
    var index = 0
    let operations: [SomeOperation]
    let completion: (Queue, Status, Action) -> ()
    var state: State = .idle
    var current: SomeOperation? {
      index < operations.count ? operations[index] : nil
    }
    init(operations: [SomeOperation], completion: @escaping (Queue, Status, Action) -> ()) {
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
    func process(status: Status, action: Action) {
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
