//
//  SampleOperations.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

import Foundation

extension SomeOperation {
  class Async: SomeOperation {
    let queue: DispatchQueue
    let action: ()->(SomeOperation.Status, SomeOperation.Action)
    init(queue: DispatchQueue, run: @escaping ()->(SomeOperation.Status, SomeOperation.Action)) {
      self.queue = queue
      self.action = run
    }
    override func run(completion: @escaping (SomeOperation.Status, SomeOperation.Action) -> ()) {
      queue.async {
        let (status, action) = self.action()
        completion(status, action)
      }
    }
  }
}
