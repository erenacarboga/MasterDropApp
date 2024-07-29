import UIKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.masterdrop.app.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh()
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.masterdrop.app.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 dakika sonra başlat

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Unable to submit task: \(error)")
        }
    }

    func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh() // Gelecek için yeni bir görev planla

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        let operation = RefreshAppOperation()
        queue.addOperation(operation)

        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }
    }
}

class RefreshAppOperation: Operation {
    override func main() {
        if self.isCancelled {
            return
        }
        // Ağ isteklerinizi ve diğer işlemleri burada gerçekleştirin
        print("App is refreshed in the background")
    }
}
