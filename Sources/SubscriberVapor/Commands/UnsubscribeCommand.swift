import SubscriberKit
import Vapor


public protocol UnsubscribeCommand: AsyncCommand {
    
    var delegate: SubscriberDelegate { get }
    
    func input(using context: CommandContext, signature: Signature) async throws -> (String)
    
}


extension UnsubscribeCommand {
    
    public func run(using context: CommandContext, signature: Signature) async throws {
        let (callback) = try await input(using: context, signature: signature)
        try await context.application
            .unsubscribe(
                callback.convertToURL(),
                on: context.application,
                delegate: delegate
            )
    }
    
}
