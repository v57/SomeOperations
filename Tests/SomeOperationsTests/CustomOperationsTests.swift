import XCTest
@testable import SomeOperations

final class CustomOperationsTests: XCTestCase {
  func testConnectOperation() {
    let connection = Connection()
    let network = NetworkQueue(connection: connection)
    network.add(ConnectOperation())
    network.runWait { error in
      XCTAssertNil(error)
    }.resume()
    XCTAssertTrue(connection.isConnected)
    XCTAssertEqual(connection.operationsCalled, 1)
  }
  func testConnectFailedOperation() {
    let connection = Connection()
    let network = NetworkQueue(connection: connection)
    network.add(ConnectFailedOperation())
    network.runWait { error in
      XCTAssertErrorEqual(error, ConnectionError.lostConnection)
    }.resume()
    XCTAssertFalse(connection.isConnected)
    XCTAssertEqual(connection.operationsCalled, 1)
  }
  
  static var allTests = [
    ("testConnectOperation", testConnectOperation),
    ("testConnectFailedOperation", testConnectFailedOperation),
  ]
}

enum ConnectionError: Error {
  case lostConnection, noData
}
class Connection {
  var operationsCalled = 0
  var isConnected = false
  var lastSent: String?
  func connect(_ completion: @escaping (Result<Void, ConnectionError>)->()) {
    operationsCalled += 1
    "ConnectQueue".queue.asyncAfter(deadline: .now() + 0.1) {
      self.isConnected = true
      completion(.success(()))
    }
  }
  func connectFailed(_ completion: @escaping (Result<Void, ConnectionError>)->()) {
    operationsCalled += 1
    "ConnectQueue".queue.asyncAfter(deadline: .now() + 0.1) {
      self.isConnected = false
      completion(.failure(.lostConnection))
    }
  }
  func send(_ some: String, completion: @escaping (Result<Void, ConnectionError>)->()) {
    operationsCalled += 1
    "ConnectQueue".queue.asyncAfter(deadline: .now() + 0.1) {
      self.lastSent = some
      completion(.success(()))
    }
  }
  func sendFailed(_ some: String, completion: @escaping (Result<Void, ConnectionError>)->()) {
    operationsCalled += 1
    "ConnectQueue".queue.asyncAfter(deadline: .now() + 0.1) {
      self.isConnected = false
      completion(.failure(.lostConnection))
    }
  }
  func read(_ completion: @escaping (Result<String, ConnectionError>)->()) {
    operationsCalled += 1
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
    operationsCalled += 1
    "ConnectQueue".queue.asyncAfter(deadline: .now() + 0.1) {
      self.isConnected = false
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
class ReadOperation: NetworkOperation {
  let completion: (String)->()
  init(completion: @escaping (String)->()) {
    self.completion = completion
  }
  override func run() {
    if connection.isConnected {
      connection.read { result in
        switch result {
        case .success(let data):
          self.completion(data)
          self.queue.next()
        case .failure(let error):
          self.queue.failed(error: error)
        }
      }
    } else {
      networkQueue.insert(ConnectOperation(), at: 0)
      networkQueue.reset()
      networkQueue.retry()
    }
  }
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

