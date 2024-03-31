import SubscriberKit
import Vapor


public protocol SubscribeCommand: AsyncCommand {
    
    var callbackURLGenerator: CallbackURLGenerator { get }
    
    var delegate: SubscriberDelegate { get }
    
    func input(
        using context: CommandContext,
        signature: Signature
    ) async throws -> (
        topic: String,
        leaseSeconds: Int?,
        preferredHub: String?
    )
    
}


extension SubscribeCommand {
    
    public func run(using context: CommandContext, signature: Signature) async throws {
        let (topic, leaseSeconds, preferredHub) = try await input(using: context, signature: signature)
        try await context.application.subscribe(
            topic: topic.convertToURL(),
            to: callbackURLGenerator.generateNewCallbackURL(),
            leaseSeconds: leaseSeconds,
            preferredHub: try? preferredHub?.convertToURL(),
            on: context.application,
            delegate: delegate
        )
    }
    
}
