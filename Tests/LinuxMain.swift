import XCTest
@testable import WLANTests

XCTMain([
    testCase(WLANTests.allTests),
    testCase(NetlinkTests.allTests)
])
