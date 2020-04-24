import XCTest
@testable import Bugless

//TODO: Create tests
final class BuglessTests: XCTestCase {
    func testWebhookIntegration_doesNotRequireCredentials() {
        
        let requiresCredential = WebhookIntegration.doesRequireCredentials()
        XCTAssertFalse(requiresCredential)
        
    }

    static var allTests = [
        ("testWebhookIntegration_doesNotRequireCredentials", testWebhookIntegration_doesNotRequireCredentials),
    ]
}
