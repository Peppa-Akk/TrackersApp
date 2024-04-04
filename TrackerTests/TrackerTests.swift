import XCTest
import SnapshotTesting

@testable import Tracker

final class TrackerTests: XCTestCase {

    func testViewController() {
        let vc = TabBarController()
        assertSnapshot(matching: vc, as: .image(traits: UITraitCollection(userInterfaceStyle: .light)))
    }
    
    func testViewCOntrollerDarkTheme() {
        let vc = TabBarController()
        
        assertSnapshot(matching: vc, as: .image(traits: UITraitCollection(userInterfaceStyle: .dark)))
    }
}
