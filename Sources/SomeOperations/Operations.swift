//
//  File.swift
//  
//
//  Created by Dmitry Kozlov on 5/21/20.
//

import Foundation

extension Operation {
  static var defaultQueue: DispatchQueue = .main
  static func run(_ run: @escaping ()->()) -> Operation {
    runWithResult(defaultResult(for: run))
  }
  static func runWithResult(_ run: @escaping (Queue)->()) -> Operation {
    Run(run: run)
  }
  static func async(on queue: DispatchQueue = defaultQueue, run: @escaping ()->()) -> Operation {
    asyncWithResult(on: queue, run: defaultResult(for: run))
  }
  static func asyncWithResult(on queue: DispatchQueue = defaultQueue, run: @escaping (Queue)->()) -> Operation {
    RunAsync(queue: queue, run: run)
  }
  static func wait(_ time: TimeInterval, on queue: DispatchQueue = defaultQueue, run: @escaping ()->()) -> Operation {
    waitWithResult(time, on: queue, run: defaultResult(for: run))
  }
  static func waitWithResult(_ time: TimeInterval, on queue: DispatchQueue = defaultQueue, run: @escaping (Queue)->()) -> Operation {
    RunWait(time: time, queue: queue, run: run)
  }
  private static func defaultResult(for action: @escaping ()->()) -> (Queue)->() {
    let result: (Queue)->() = { queue in
      action()
      queue.next()
    }
    return result
  }
}

extension Operation {
  class RunAsync: Operation {
    let dispatchQueue: DispatchQueue
    let action: (Queue)->()
    init(queue: DispatchQueue, run: @escaping (Queue)->()) {
      self.dispatchQueue = queue
      self.action = run
    }
    override func run() {
      dispatchQueue.async {
        self.action(self.queue)
      }
    }
  }
  class RunWait: Operation {
    let time: TimeInterval
    let dispatchQueue: DispatchQueue
    let action: (Queue)->()
    var isCancelled = false
    init(time: TimeInterval, queue: DispatchQueue, run: @escaping (Queue)->()) {
      self.time = time
      self.dispatchQueue = queue
      self.action = run
    }
    override func run() {
      isCancelled = false
      dispatchQueue.asyncAfter(wallDeadline: .now() + time) {
        self.waited()
      }
    }
    func waited() {
      guard !isCancelled else { return }
      action(queue)
    }
    override func cancel() {
      isCancelled = true
      queue.reset()
      isCancelled = false
    }
  }
  class Run: Operation {
    let action: (Queue)->()
    init(run: @escaping (Queue)->()) {
      self.action = run
    }
    override func run() {
      action(queue)
    }
  }
}
