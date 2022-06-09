import Foundation
import UIKit
import RxSwift
import RxCocoa

class TaskListViewController: UIViewController {
    @IBOutlet weak var prioritySegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    private var tasks = BehaviorRelay<[Task]>(value:[])
    private var filteredTasks = [Task]()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure(self.tableView)
    }
    
    private func configure(_ tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navC = segue.destination as? UINavigationController, let addTaskVC = navC.viewControllers.first as? AddTaskViewController else {
            fatalError("Controller not found")
        }
        
        let priority = Priority(rawValue: self.prioritySegmentedControl.selectedSegmentIndex - 1)
        
        addTaskVC.taskObservable.subscribe(onNext: {[unowned self] task in
            var existingTasks = self.tasks.value
            existingTasks.append(task)
            self.tasks.accept(existingTasks)
            
            self.filteringTasks(by: priority)
        }).disposed(by: disposeBag)
    }

    private func filteringTasks(by priority: Priority?) {
        if priority == nil {
            self.filteredTasks = self.tasks.value
            self.updateTableView()
        } else {
            self.tasks.map { tasks in
                return tasks.filter {
                    $0.Priority == priority!
                }
            }.subscribe(onNext: { [weak self] tasks in
                self?.filteredTasks = tasks
                self?.updateTableView()
            }).disposed(by: disposeBag)
        }
    }
    
    @IBAction func priorityValueChange(segmentedControl: UISegmentedControl) {
        let priority = Priority(rawValue: segmentedControl.selectedSegmentIndex-1)
        filteringTasks(by: priority)
    }
    
    private func updateTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension TaskListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath)
        cell.textLabel?.text = self.filteredTasks[indexPath.row].title
        return cell
    }
}

extension TaskListViewController: UITableViewDelegate {}
