//
//  SampleOperations.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

import Foundation

extension SomeOperation {
  static var defaultQueue: DispatchQueue = .main
  static func run(_ run: @escaping ()->()) -> SomeOperation {
    runWithResult(defaultResult(for: run))
  }
  static func runWithResult(_ run: @escaping ()->(Status, Action)) -> SomeOperation {
    Run(run: run)
  }
  static func async(on queue: DispatchQueue = defaultQueue, run: @escaping ()->()) -> SomeOperation {
    asyncWithResult(on: queue, run: defaultResult(for: run))
  }
  static func asyncWithResult(on queue: DispatchQueue = defaultQueue, run: @escaping ()->(Status, Action)) -> SomeOperation {
    RunAsync(queue: queue, run: run)
  }
  private static func defaultResult(for action: @escaping ()->()) -> ()->(Status, Action) {
    let result: ()->(Status, Action) = {
      action()
      return (.done, .next)
    }
    return result
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
  class Run: SomeOperation {
    let action: ()->(Status, Action)
    init(run: @escaping ()->(Status, Action)) {
      self.action = run
    }
    override func run(completion: @escaping (Status, Action) -> ()) {
      let (status, action) = self.action()
      completion(status, action)
    }
  }
}
