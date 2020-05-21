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
    if removeCompletedOperations {
      if index > 0 {
        operations.removeSubrange(0..<index)
        index = 0
      }
    }
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
typealias QueueCompletion = ()->()
class CompletionQueue: Queue {
  let completion: QueueCompletion
  init(completion: @escaping QueueCompletion) {
    self.completion = completion
  }
}
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
  func cancel() {
    
  }
}

/*
 let queue = SomeOperationQueue()
 queue.removeCompletedOperations = true
 queue.add { queue in
  doSome()
 }
 queue.add {
  if isConnected {
    run { result in
      if result.isLostConnection {
        queue.reset()
      }
    }
  } else {
    queue.insert(ConnectOperation(), at: queue.index)
    queue.retry()
  }
 }
 
 // ConnectOperation {
   if isConnected {
    queue.removeCurrent()
    queue.retry()
  }
 */
