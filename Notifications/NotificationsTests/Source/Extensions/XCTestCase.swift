import XCTest

typealias fulfill = () -> Void

extension XCTestCase {
    
    func expectSyncCallback(count expectedCount: Int = 1, file: StaticString = #file, line: UInt = #line, during work: (@escaping fulfill) -> Void) {
        var callbackCount = 0
        work {
            callbackCount += 1
        }
        if callbackCount != expectedCount {
            XCTFail("Expected callback count (\(expectedCount)) does not match actual (\(callbackCount))", file: file, line: line)
        }
    }
    
}
