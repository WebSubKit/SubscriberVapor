import SubscriberKit
import Vapor


extension SubscriberError: AbortError {
    
    public var status: HTTPResponseStatus {
        switch self {
        case .failedToCreateURLFrom:
            return .badRequest
        case .receivingPayloadForInvalid:
            return .gone
        case .verificationNotRequested:
            return .notFound
        case .validationFailedToIdentifiedBy:
            return .badRequest
        case .subscriptionNotFoundForCallback:
            return .gone
        case .failedToPerformDiscoveryMechanism(_, _):
            return .badRequest
        }
    }
    
}
