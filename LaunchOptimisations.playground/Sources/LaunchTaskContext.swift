import Foundation

import Foundation

/// Represents the context in which an app launch task is executed.
public enum LaunchTaskContext {
    /// Task is executed synchronously.
    case sync
    
    /// Task is executed asynchronously.
    case async
    
    /// Task is executed on a custom dispatch queue.
    case custom(DispatchQueue)
}
