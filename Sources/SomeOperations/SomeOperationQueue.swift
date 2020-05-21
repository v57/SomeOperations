//
//  SomeOperationQueue.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

import Swift

class SomeOperationQueue: SomeOperation {
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
