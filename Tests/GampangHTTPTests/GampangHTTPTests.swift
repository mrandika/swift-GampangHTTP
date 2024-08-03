import XCTest
@testable import GampangHTTP

struct HttpBin: Decodable {
    let url: String
}

final class GampangHTTPTests: XCTestCase {
    func testExample() async throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        
        let url: String = "https://httpbin.org/get"
        
        let request = try GampangURLRequest(url: url, method: .get).build
        let result = try await GampangHTTP.request(with: request, of: HttpBin.self)
        
        XCTAssertEqual(result.url, url)
    }
}
