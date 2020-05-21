//
//  SomeOperations.swift
//
//
//  Created by Dmitry Kozlov on 5/21/20.
//

class SomeOperations: SomeOperation {
  var operations: [SomeOperation] = []
  override func run(completion: @escaping (Status, Action) -> ()) {
    state = .running
    let queue = Queue(operations: operations) { [unowned self] queue, status, action in
      self.state = .completed
      self.queues.remove(queue)
      completion(status, action)
    }
    queues.insert(queue)
    queue.resume()
  }
}
