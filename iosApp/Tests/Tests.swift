import XCTest
import Shared

final class SharedTests: XCTestCase {
    func testConsoleReportContainsSections() {
        let report = ConsoleReportBuilder().build()

        XCTAssertTrue(report.contains("== Declarations =="))
        XCTAssertTrue(report.contains("== Primitive Mappings =="))
        XCTAssertTrue(report.contains("== Coroutines =="))
    }
}
