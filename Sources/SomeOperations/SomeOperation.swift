//
//  SomeOperation.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

class SomeOperation {
  enum Status {
    case done, failed(Error)
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
    state = .completed
    completion(.done, .next)
  }
  class Queue {
    var index = 0
    let operations: [SomeOperation]
    let completion: (Status, Action) -> ()
    init(index: Int, completion: @escaping (Status, Action) -> ()) {
      self.operations = operations
      self.completion = completion
    }
    func start() -> Self {
      next()
      return self
    }
    func next() {
      guard index < operations.count else {
        done()
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
        next()
      case .failed(let error):
        done(status: status, action: action)
      }
    }
    func done(status: Status, action: Action) {
      completion(status, action)
    }
  }
}
