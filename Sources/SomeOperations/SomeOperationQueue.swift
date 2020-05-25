//
//  SomeOperationQueue.swift
//
//
//  Created by Dmitry Kozlov on 5/21/20.
//

import Swift

open class SomeOperationQueue: SomeOperation {
  open var queueName: String { String(describing: type(of: self)) }
  open override var name: String {
    var name = queueName + "\n"
    for (index, operation) in operations.enumerated() {
      if self.index == index {
        name += "-"
      } else {
        name += "."
      }
      name += operation.name.replacingOccurrences(of: "\n", with: "\n.") + "\n"
    }
    if operations.count > 0 {
      name.removeLast()
    }
    return name
  }
  open var index: Int = 0
  open var operations = [SomeOperation]()
  open var removeCompletedOperations = false
  public var isRunning = false
  public var isEnabled = true
  open override var totalOperations: Int {
    operations.reduce(0, { $0 + $1.totalOperations })
  }
  open var current: SomeOperation? {
    index < operations.count ? operations[index] : nil
  }
  open override func run() {
    resume()
  }
  open func addNext(_ operation: SomeOperation) {
    if isRunning {
      self.operations.insert(operation, at: index + 1)
    } else {
      self.operations.insert(operation, at: index)
    }
  }
  open func add(_ operation: SomeOperation) {
    self.operations.append(operation)
  }
  open func resume() {
    guard isEnabled else { return }
    guard !isRunning else { return }
    isRunning = true
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
    isRunning = false
    queue?.next()
  }
  open override func cancel() {
    isRunning = false
    queue?.reset()
    queue?.cancel()
  }
  open override func pause() {
    isRunning = false
    queue?.pause()
  }
  open override func failed(error: Error) {
    isRunning = false
    queue?.failed(error: error)
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
    isRunning = false
    resume()
  }
  open func next() {
    isRunning = false
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
