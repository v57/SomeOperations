import XCTest
@testable import SomeOperations

final class CustomOperationsTests: XCTestCase {
  func testConnectOperation() {
    
  }
  
  static var allTests = [
    ("testConnectOperation", testConnectOperation),
  ]
}

enum ConnectionError: Error {
  case lostConnection, noData
}
class Connection {
  var isConnected = false
  var lastSent: String?
  func connect(_ completion: @escaping (Result<Void, ConnectionError>)->()) {
    "ConnectQueue".queue.asyncAfter(deadline: .now() + 0.1) {
      completion(.success(()))
    }
  }
  func connectFailed(_ completion: @escaping (Result<Void, ConnectionError>)->()) {
    "ConnectQueue".queue.asyncAfter(deadline: .now() + 0.1) {
      completion(.failure(.lostConnection))
    }
  }
  func send(_ some: String, completion: @escaping (Result<Void, ConnectionError>)->()) {
    "ConnectQueue".queue.asyncAfter(deadline: .now() + 0.1) {
      self.lastSent = some
      completion(.success(()))
    }
  }
  func sendFailed(_ some: String, completion: @escaping (Result<Void, ConnectionError>)->()) {
    "ConnectQueue".queue.asyncAfter(deadline: .now() + 0.1) {
      completion(.failure(.lostConnection))
    }
  }
  func read(_ completion: @escaping (Result<String, ConnectionError>)->()) {
    "ConnectQueue".queue.asyncAfter(deadline: .now() + 0.1) {
      if let lastSent = self.lastSent {
        self.lastSent = nil
        completion(.success(lastSent))
      } else {
        completion(.failure(.noData))
      }
    }
  }
  func readFailed(_ completion: @escaping (Result<String, ConnectionError>)->()) {
    "ConnectQueue".queue.asyncAfter(deadline: .now() + 0.1) {
      completion(.failure(.lostConnection))
    }
  }
}
class NetworkQueue: Queue {
  var connection: Connection
  init(connection: Connection) {
    self.connection = connection
  }
}
class NetworkOperation: SomeOperation {
  var networkQueue: NetworkQueue {
    if let queue = queue as? NetworkQueue {
      return queue
    } else {
      fatalError("Network operations should run from network queue")
    }
  }
  var connection: Connection { networkQueue.connection }
}
class ConnectOperation: NetworkOperation {
  override func run() {
    if connection.isConnected {
      self.queue.removeCurrent()
      self.queue.retry()
    } else {
      connection.connect { result in
        self.queue.removeCurrent()
        switch result {
        case .success:
          self.queue.retry()
        case .failure(let error):
          self.queue.failed(error: error)
        }
      }
    }
  }
}

class ConnectFailedOperation: NetworkOperation {
  override func run() {
    if connection.isConnected {
      self.queue.removeCurrent()
      self.queue.retry()
    } else {
      connection.connectFailed { result in
        self.queue.removeCurrent()
        switch result {
        case .success:
          self.queue.retry()
        case .failure(let error):
          self.queue.failed(error: error)
        }
      }
    }
  }
}

