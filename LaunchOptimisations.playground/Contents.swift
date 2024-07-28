
import UIKit

LaunchTaskExecutor.execute {
    SyncLaunchTask({
        
    }, taskName: "SyncLaunchTask")
    
    SyncLaunchTask({
        return "SyncLaunchTaskWithOutput Complete"
    }, taskName: "SyncLaunchTaskWithOutput", output: { output in
        print("Output of SyncLaunchTaskWithOutput is \(output)")
    })
    
    AsyncLaunchTask({
        return true
    }, taskName: "AsyncLaunchTask")
    
    AsyncLaunchTask({
        return 1234
    }, taskName: "AsyncLaunchTaskWithOutput Complete") { output in
        print("Output of AsyncLaunchTaskWithOutput is \(output)")
    }
    
    DatabaseAsyncTask({
        let key = Double.random(in: 1...1000)
        return "Encription Key\(Int(key))"
    }, taskName: "DatabaseAsyncTask", output: { output in
        print("Output of DatabaseAsyncTask is \(output)")
    })

    
}

struct DatabaseAsyncTask: LaunchTask {
    typealias EncriptionKey = String
    private var body: () -> EncriptionKey
    public var output: ((EncriptionKey) -> Void)?
    public let taskName: String

    public let context: LaunchTaskContext = .async
    
    internal init(
        _ body: @escaping () -> EncriptionKey, taskName: String, output: ((EncriptionKey) -> Void)? = nil) {
        self.body = body
        self.output = output
        self.taskName = taskName+"LaunchAsyncTask"
    }
    
    func execute() {
        let value = body()
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            output?(value)
        }
    }
}
