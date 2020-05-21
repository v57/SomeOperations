//
//  SomeOperations.swift
//
//
//  Created by Dmitry Kozlov on 5/21/20.
//

class SomeOperations: SomeOperation {
  var operations: [SomeOperation] = []
  override func run(completion: @escaping (Status, Action) -> ()) {
    let queue = SomeOperationQueue(operations: operations) { [unowned self] queue, status, action in
      self.queues.remove(queue)
      completion(status, action)
    }
    queues.insert(queue)
    queue.resume()
  }
  func add(_ operation: SomeOperation) {
    self.operations.append(operation)
  }
}
