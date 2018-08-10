import XCTest
@testable import WLANTests
@testable import NetlinkTests

XCTMain([
    testCase(WLANTests.allTests),
    testCase(NetlinkTests.allTests)
    testCase(NL80211Tests.allTests)
])
