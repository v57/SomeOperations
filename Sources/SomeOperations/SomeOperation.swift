//
//  SomeOperation.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

import Swift

typealias QueueCompletion = (Error?)->()
class CompletionQueue: SomeOperationQueue {
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
  weak var queue: SomeOperationQueue!
  var totalOperations: Int { 1 }
  func run(completion: @escaping QueueCompletion) -> CompletionQueue {
    let queue = CompletionQueue(completion: completion)
    queue.add(self)
    return queue
  }
  func run() {
    queue.next()
  }
  func cancel() {
    queue?.reset()
    queue?.cancel()
  }
  func pause() {
    queue?.pause()
  }
  func failed(error: Error) {
    queue?.failed(error: error)
  }
}
