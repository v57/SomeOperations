//
//  File.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

import Foundation

class Queue: Operation {
  var index: Int = 0
  var operations = [Operation]()
  var removeCompletedOperations = false
  var current: Operation? {
    index < operations.count ? operations[index] : nil
  }
  override func run() {
    resume()
  }
  func resume() {
    if let current = current {
      current.queue = self
      current.run()
    } else {
      done()
    }
  }
  func reset() {
    index = 0
  }
  func done() {
    queue?.next()
  }
  func insert(_ operations: Operation..., at index: Int, updateIndex: Bool = false) {
    if updateIndex && self.index >= index {
      self.index += operations.count
    }
    insert(operations, at: index)
  }
  func insert(_ operations: [Operation], at index: Int, updateIndex: Bool = false) {
    self.operations.insert(contentsOf: operations, at: index)
  }
  func retry() {
    resume()
  }
  func next() {
    index += 1
    resume()
  }
}
  }
  func hash(into hasher: inout Hasher) {
    ObjectIdentifier(self).hash(into: &hasher)
class Operation {
  weak var queue: Queue!
  func run(completion: @escaping QueueCompletion) -> CompletionQueue {
    let queue = CompletionQueue(completion: completion)
    self.queue = queue
    run()
    return queue
  }
  func run() {
    
  }
}
