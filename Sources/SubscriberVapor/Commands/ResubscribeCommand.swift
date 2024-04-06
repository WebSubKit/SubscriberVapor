import SubscriberKit
import Vapor


public protocol ResubscribeCommand: AsyncCommand {
    
    var callbackURLGenerator: CallbackURLGenerator { get }
    
    var delegate: SubscriberDelegate { get }
    
    var bothCallbackAndTopicPresentErrorMessage: String { get }
    
    func input(
        using context: CommandContext,
        signature: Signature
    ) async throws -> (
        resubscribeAll: Bool,
        topic: String?,
        callback: String?,
        leaseSeconds: Int?
    )
    
    func confirmUserBeforeResubscribeAllSubscriptions(
        using context: CommandContext
    ) async throws -> Bool
    
}


extension ResubscribeCommand {
    
    public func run(using context: CommandContext, signature: Signature) async throws {
        let (resubscribeAll, topic, callback, leaseSeconds) = try await input(
            using: context,
            signature: signature
        )
        if resubscribeAll {
            try await resubscribeAllSubscriptions(
                leaseSeconds: leaseSeconds,
                using: context
            )
            return
        }
        if callback != nil && topic != nil {
            context.console.output(
                bothCallbackAndTopicPresentErrorMessage,
                style: .error,
                newLine: true
            )
            return
        }
        if let callback {
            try await context.application.resubscribe(
                callback: callback.convertToURL(),
                leaseSeconds: leaseSeconds,
                on: context.application,
                delegate: delegate
            )
        }
        if let topic {
            try await context.application.resubscribe(
                topic: topic.convertToURL(),
                leaseSeconds: leaseSeconds,
                on: context.application,
                delegate: delegate
            )
        }
        let confirmed = try await confirmUserBeforeResubscribeAllSubscriptions(
            using: context
        )
        if callback == nil && topic == nil && confirmed {
            try await resubscribeAllSubscriptions(
                leaseSeconds: leaseSeconds,
                using: context
            )
        }
    }
    
    private func resubscribeAllSubscriptions(
        leaseSeconds: Int?,
        using context: CommandContext
    ) async throws {
        for subscription in try await context.application.subscriptions() {
            try await context.application.resubscribe(
                callback: subscription.callback,
                leaseSeconds: leaseSeconds,
                on: context.application,
                delegate: delegate
            )
        }
    }
    
}
