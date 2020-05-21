//
//  File.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

import Foundation

    index < operations.count ? operations[index] : nil
  }
  }
  func resume() {
    }
      done(status: status, action: action)
    }
  }
  func done(status: SomeOperation.Status, action: SomeOperation.Action) {
    completion(self, status, action)
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
