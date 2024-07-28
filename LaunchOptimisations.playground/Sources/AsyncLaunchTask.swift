import Foundation

/// A struct representing an asynchronous background task that executes during app launch.
public struct AsyncLaunchTask<Output>: LaunchTask {
    
    /// The task to be executed.
    private let body: () -> Output
    
    /// The callback to be executed with the task's output.
    public let output: ((Output) -> Void)?
    
    /// The name of the task.
    public let taskName: String
    
    /// The context in which the task is executed.
    public let context: LaunchTaskContext
    
    /// Initializes an `AsyncLaunchTask`.
    ///
    /// - Parameters:
    ///   - body: The task to be executed.
    ///   - taskName: The name of the task.
    ///   - output: An optional callback to be executed with the task's output.
    ///   - context: The context in which the task is executed. Defaults to `.async`.
    public init(_ body: @escaping () -> Output,
                taskName: String,
                output: ((Output) -> Void)? = nil,
                context: LaunchTaskContext = .async) {
        self.body = body
        self.output = output
        self.taskName = taskName + "LaunchAsyncTask"
        self.context = context
    }
    
    /// Executes the task and calls the output callback with the result.
    public func execute() {
        let value = body()
        output?(value)
    }
}
