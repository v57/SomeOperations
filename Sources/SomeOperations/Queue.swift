//
//  File.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

import Foundation

class Queue: SomeOperation {
  var index: Int = 0
  var operations = [SomeOperation]()
  var removeCompletedOperations = false
  override var totalOperations: Int {
    operations.reduce(0, { $0 + $1.totalOperations })
  }
  var current: SomeOperation? {
    index < operations.count ? operations[index] : nil
  }
  override func run() {
    resume()
  }
  func add(_ operation: SomeOperation) {
    self.operations.append(operation)
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
  func clear() {
    operations.removeAll()
    index = 0
  }
  func done() {
    queue?.next()
  }
  func removeCurrent() {
    operations.remove(at: index)
  }
  func insert(_ operations: SomeOperation..., at index: Int, updateIndex: Bool = false) {
    if updateIndex && self.index >= index {
      self.index += operations.count
    }
    insert(operations, at: index)
  }
  func insert(_ operations: [SomeOperation], at index: Int, updateIndex: Bool = false) {
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
typealias QueueCompletion = (Error?)->()
class CompletionQueue: Queue {
  let completion: QueueCompletion
  init(completion: @escaping QueueCompletion) {
    self.completion = completion
  }
  override func cancel() {
    completion(nil)
  }
  override func done() {
    completion(nil)
  }
  override func failed(error: Error) {
    completion(error)
  }
}
class SomeOperation {
  weak var queue: Queue!
  var totalOperations: Int { 1 }
  func run(completion: @escaping QueueCompletion) -> CompletionQueue {
    let queue = CompletionQueue(completion: completion)
    queue.add(self)
    return queue
  }
  func run() {
    
  }
  func cancel() {
    
  }
  func pause() {
    queue?.pause()
  }
  func failed(error: Error) {
    queue?.failed(error: error)
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
