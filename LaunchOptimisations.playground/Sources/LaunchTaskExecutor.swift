import Foundation


import Foundation

/// A struct to execute app launch tasks.
public struct LaunchTaskExecutor {
    /// Executes the provided app launch tasks based on their context.
    ///
    /// - Parameter builder: A closure that returns an array of `LaunchTask` instances.
    public static func execute(@LaunchTaskBuilder builder: () -> [LaunchTask]) {
        builder().forEach { task in
            switch task.context {
            case .sync:
                task.executeTask()
            case .async:
                DispatchQueue.global().async {
                    task.executeTask()
                }
            case .custom(let dispatchQueue):
                dispatchQueue.async {
                    task.executeTask()
                }
            }
        }
    }
}

/// A result builder for creating an array of `LaunchTask` instances.
@resultBuilder
public struct LaunchTaskBuilder {
    public static func buildBlock(_ components: LaunchTask...) -> [LaunchTask] {
        components
    }

    public static func buildExpression(_ expression: LaunchTask) -> LaunchTask {
        expression
    }

    public static func buildEither(first component: LaunchTask) -> LaunchTask {
        component
    }

    public static func buildEither(second component: LaunchTask) -> LaunchTask {
        component
    }

    public static func buildOptional(_ component: LaunchTask?) -> LaunchTask? {
        component
    }
}
