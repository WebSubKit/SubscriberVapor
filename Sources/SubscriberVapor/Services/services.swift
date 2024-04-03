import Fluent
import SubscriberFluent
import SubscriberKit
import Vapor


extension Application: Subscriber {
    
    public var httpCallProvider: HTTPCallProvider {
        VaporClientHTTPCallProvider(client)
    }
    
}


extension Request: Subscriber {
    
    public var httpCallProvider: HTTPCallProvider {
        VaporClientHTTPCallProvider(client)
    }
    
}


extension Application: SubscriberFluentRepository {
    
    public var fluentDatabase: Database { db }
    
}


extension Request: SubscriberFluentRepository {
    
    public var fluentDatabase: Database { db }
    
}


private final class VaporClientHTTPCallProvider: HTTPCallProvider {
    
    private let client: Client
    
    init(_ client: Client) {
        self.client = client
    }
    
    func makeHTTPCall(
        to url: URL,
        method: HTTPMethod,
        headers: [(String, String)],
        body: Data?
    ) async throws -> ([(String, String)], Data?) {
        var request = ClientRequest(
            method: method,
            url: URI(string: url.absoluteString),
            headers: HTTPHeaders(headers)
        )
        if let body {
            request.body = client.byteBufferAllocator.buffer(data: body)
        }
        let response = try await client.send(request)
        if !response.status.isSuccess {
            throw HTTPError(from: response.status)
        }
        if var responseBody = response.body {
            return (
                response.headers.map({ ($0, $1) }),
                responseBody.readData(length: responseBody.readableBytes)
            )
        }
        return (response.headers.map({ ($0, $1) }), nil)
    }
    
}


extension HTTPResponseStatus {
    
    fileprivate var isSuccess: Bool {
        return code >= 200 && code <= 300
    }
    
}


private struct HTTPError: LocalizedError {
    
    let status: HTTPStatus
    
    public var errorDescription: String? { status.reasonPhrase }
    
    init(from status: HTTPStatus) {
        self.status = status
    }
    
}
