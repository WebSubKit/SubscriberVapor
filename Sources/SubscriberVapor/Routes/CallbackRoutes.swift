import SubscriberKit
import Vapor


public protocol CallbackRoutes: RouteCollection {
    
    var callbackURLGenerator: CallbackURLGenerator { get }
    
    var delegate: SubscriberDelegate { get }
    
}


extension CallbackRoutes {
    
    public func verify(_ request: Request, validation: SubscriptionValidation) async throws -> Response {
        try await request.verify(
            validation,
            from: request.findCallbackURL(with: callbackURLGenerator),
            on: request,
            delegate: delegate
        )
        switch validation {
        case .verifying(let verifying):
            return try await verifying.challenge.encodeResponse(status: .accepted, for: request)
        case .denied:
            return Response(status: .accepted)
        }
    }
    
    public func deliver(request: Request) async throws -> Response {
        guard
            var requestData = request.body.data,
            let data = requestData.readData(length: requestData.readableBytes)
        else {
            return Response(status: .badRequest)
        }
        try await request.receive(
            data,
            from: request.findCallbackURL(with: callbackURLGenerator),
            on: request,
            delegate: delegate
        )
        return Response(status: .accepted)
    }
    
}


extension Request {
    
    fileprivate func findCallbackURL(with callbackURLGenerator: CallbackURLGenerator) async throws -> URL {
        guard let callbackID = parameters.get("id") else { throw HTTPStatus.notFound }
        return try callbackURLGenerator.findCallbackURL(for: callbackID)
    }
    
}


extension HTTPResponseStatus: Error { }
