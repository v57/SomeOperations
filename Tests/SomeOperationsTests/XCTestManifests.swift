import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(QueueTests.allTests),
        testCase(CustomOperationsTests.allTests),
    ]
}
#endif
