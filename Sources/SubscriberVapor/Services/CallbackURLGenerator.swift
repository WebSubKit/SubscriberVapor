import Foundation
import SubscriberKit
import Vapor


public protocol CallbackURLGenerator {
    
    var baseURL: String { get }
    
    var callbackPath: String { get }
    
}


extension CallbackURLGenerator {
    
    public func generateNewCallbackURL() async throws -> URL {
        try findCallbackURL(for: UUID().uuidString)
    }
    
    public func findCallbackURL(for identifier: String) throws -> URL {
        try "\(baseURL.dropSuffix("/"))/\(callbackPath.dropSuffix("/"))/\(identifier)".convertToURL()
    }
    
}


// MARK: - Private Utilities

extension String {
    
    fileprivate func dropSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else {
            return self
        }
        return String(dropLast(suffix.count))
    }
    
}
