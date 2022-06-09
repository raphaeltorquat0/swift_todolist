import Foundation
import UIKit
import RxSwift

class AddTaskViewController: UIViewController {
    
    private let taskSubject = PublishSubject<Task>()
    var taskObservable: Observable<Task> {
        return taskSubject.asObservable()
    }
    
    @IBOutlet weak var prioritySegmentedControl: UISegmentedControl!
    @IBOutlet weak var textTitleTextField: UITextField!
    
    @IBAction func save() {
        guard let priority = Priority(rawValue: self.prioritySegmentedControl.selectedSegmentIndex),
                let title = self.textTitleTextField.text else { return }
        let task = Task(title: title, Priority: priority)
        taskSubject.onNext(task)
        self.dismiss(animated: true)
    }
}
