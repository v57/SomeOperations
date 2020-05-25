//
//  SomeOperation.swift
//
//
//  Created by Dmitry Kozlov on 5/21/20.
//

import Swift

public typealias QueueCompletion = (Error?)->()
open class CompletionQueue: SomeOperationQueue {
  public let completion: QueueCompletion
  public init(completion: @escaping QueueCompletion) {
    self.completion = completion
  }
  open override func cancel() {
    completion(nil)
  }
  open override func done() {
    completion(nil)
  }
  open override func failed(error: Error) {
    completion(error)
  }
}
open class SomeOperation {
  open var name: String { className(self) }
  open weak var queue: SomeOperationQueue!
  open var totalOperations: Int { 1 }
  public init() {}
  open func run(completion: @escaping QueueCompletion) -> CompletionQueue {
    let queue = CompletionQueue(completion: completion)
    queue.add(self)
    return queue
  }
  open func run() {
    queue.next()
  }
  open func cancel() {
    queue?.reset()
    queue?.cancel()
  }
  open func pause() {
    queue?.pause()
  }
  open func failed(error: Error) {
    queue?.failed(error: error)
  }
}
