//
//  SomeOperationQueue.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

import Swift

open class SomeOperationQueue: SomeOperation {
  open var index: Int = 0
  open var operations = [SomeOperation]()
  open var removeCompletedOperations = false
  open override var totalOperations: Int {
    operations.reduce(0, { $0 + $1.totalOperations })
  }
  open var current: SomeOperation? {
    index < operations.count ? operations[index] : nil
  }
  open override func run() {
    resume()
  }
  open func add(_ operation: SomeOperation) {
    self.operations.append(operation)
  }
  open func resume() {
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
  open func reset() {
    index = 0
  }
  open func clear() {
    operations.removeAll()
    index = 0
  }
  open func done() {
    queue?.next()
  }
  open func removeCurrent() {
    operations.remove(at: index)
  }
  open func insert(_ operations: SomeOperation..., at index: Int, updateIndex: Bool = false) {
    if updateIndex && self.index >= index {
      self.index += operations.count
    }
    insert(operations, at: index)
  }
  open func insert(_ operations: [SomeOperation], at index: Int, updateIndex: Bool = false) {
    self.operations.insert(contentsOf: operations, at: index)
  }
  open func retry() {
    resume()
  }
  open func next() {
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
