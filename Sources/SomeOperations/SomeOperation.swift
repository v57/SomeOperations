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
  var queues = [Queue]()
  func run(completion: @escaping (Status, Action)->()) {
    state = .completed
    completion(.done, .next)
  }
}
