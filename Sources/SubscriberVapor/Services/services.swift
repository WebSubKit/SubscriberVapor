import Fluent
import SubscriberFluent
import SubscriberKit
import Vapor


extension Application: Subscriber { }


extension Request: Subscriber { }


extension Application: SubscriberFluentRepository {
    
    public var fluentDatabase: Database { db }
    
}


extension Request: SubscriberFluentRepository {
    
    public var fluentDatabase: Database { db }
    
}
