import Foundation
import SwiftKeychainWrapper

final class AuthStorage {
    
    static let shared = AuthStorage()
    
    private let keychaingWrapper = KeychainWrapper.standard
    private let firstJoinKey = "firstJoin"
    
    var firstJoin: Bool? {
        get {
            keychaingWrapper.bool(forKey: firstJoinKey)
        }
        set {
            if let firstJoin = newValue {
                keychaingWrapper.set(firstJoin, forKey: firstJoinKey)
            } else {
                keychaingWrapper.removeObject(forKey: firstJoinKey)
            }
        }
    }
    
    
    func cleanData() {
        keychaingWrapper.removeObject(forKey: firstJoinKey)
    }
}
