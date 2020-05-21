//
//  SampleOperations.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

import Foundation

extension SomeOperation {
  static var defaultQueue: DispatchQueue = .main
  static func asyncWithResult(on queue: DispatchQueue = defaultQueue, run: @escaping ()->(Status, Action)) -> SomeOperation {
    RunAsync(queue: queue, run: run)
  }
}

extension SomeOperation {
  class RunAsync: SomeOperation {
    let queue: DispatchQueue
    let action: ()->(Status, Action)
    init(queue: DispatchQueue, run: @escaping ()->(Status, Action)) {
      self.queue = queue
      self.action = run
    }
    override func run(completion: @escaping (Status, Action) -> ()) {
      queue.async {
        let (status, action) = self.action()
        completion(status, action)
      }
    }
  }
}
