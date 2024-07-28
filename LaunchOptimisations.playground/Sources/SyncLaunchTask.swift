import Foundation

/// A struct representing a synchronous task that executes during app launch.
public struct SyncLaunchTask<Output>: LaunchTask {
    
    /// The task to be executed.
    private let body: () -> Output
    
    /// The callback to be executed with the task's output.
    private let output: ((Output) -> Void)?
    
    /// The name of the task.
    public let taskName: String
    
    /// The context in which the task is executed.
    public let context: LaunchTaskContext = .sync
    
    /// Initializes an `LaunchSyncTask`.
    ///
    /// - Parameters:
    ///   - body: The task to be executed.
    ///   - taskName: The name of the task.
    ///   - output: An optional callback to be executed with the task's output.
    public init(_ body: @escaping () -> Output, taskName: String, output: ((Output) -> Void)? = nil) {
        self.body = body
        self.output = output
        self.taskName = taskName + "LaunchSyncTask"
    }
    
    /// Executes the task and calls the output callback with the result.
    public func execute() {
        let value = body()
        output?(value)
    }
}

