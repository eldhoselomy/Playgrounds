import Foundation
import OSLog

/// Protocol representing a task to be executed during app launch.
public protocol LaunchTask {
    /// Executes the task.
    func execute()
    
    /// The name of the task.
    var taskName: String { get }
    
    /// The context in which the task is executed.
    var context: LaunchTaskContext { get }
}

public extension LaunchTask {
    /// Executes the task and logs the execution.
    func executeTask() {
        print("Executing \(taskName)")
        LaunchLogger.logger.trace("Executing \(taskName)")
        execute()
    }

    /// The name of the task, defaulting to the type name.
    var taskName: String {
        return String(describing: Self.self)
    }
}

/// Logger for launch tasks.
internal final class LaunchLogger {
    /// Shared logger instance.
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app.launchTask", category: "LaunchTask")
}
