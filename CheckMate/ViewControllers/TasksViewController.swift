//
//  TasksViewController.swift
//  CheckMate
//
//  Created by Paul Makey on 21.02.24.
//

import UIKit
import RealmSwift

final class TasksViewController: UITableViewController {
    
    // MARK: - Public Properties
    var taskTitle: TaskTitle!
    
    // MARK: - Private Properties
    private let storageManager = StorageManager.shared
    private var currentTasks: Results<Task>!
    private var completedTasks: Results<Task>!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = taskTitle.title
        
        currentTasks = taskTitle.tasks.filter("isComplete = false")
        completedTasks = taskTitle.tasks.filter("isComplete = true")
    }
    
    // MARK: - IB Actions
    @IBAction func addButtonDidTapped(_ sender: UIBarButtonItem) {
        showAlert()
    }
}

// MARK: - UITableViewDataSource
extension TasksViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "CURRENT TASKS" : "COMPLETED TASKS"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? currentTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let task = indexPath.section == 0
        ? currentTasks[indexPath.row]
        : completedTasks[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        content.secondaryText = task.note
        
        cell.contentConfiguration = content
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension TasksViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        let task = indexPath.section == 0
        ? currentTasks[indexPath.row]
        : completedTasks[indexPath.row]
        
        let doneAction = UIContextualAction(
            style: .normal,
            title: indexPath.section == 0 ? "Done" : "Undone") { [unowned self] _, _, isDone in
                
                storageManager.done(forTask: task)
                
                let currentTasksIndexPath = IndexPath(
                    row: currentTasks.firstIndex(of: task) ?? 0,
                    section: 0
                )
                let completedTasksIndexPath = IndexPath(
                    row: completedTasks.firstIndex(of: task) ?? 0,
                    section: 1
                )
                
                let destinationIndexPath = indexPath.section == 0
                ? completedTasksIndexPath
                : currentTasksIndexPath
                
                tableView.moveRow(at: indexPath, to: destinationIndexPath)
                
                isDone(true)
            }
        
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit") { [unowned self] _, _, isDone in
                showAlert(with: task) {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                isDone(true)
            }
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete") { [unowned self] _, _, _ in
                storageManager.deleteTask(task)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        
        doneAction.backgroundColor = .systemGreen
        editAction.backgroundColor = .systemOrange
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
}

// MARK: - Alert
private extension TasksViewController {
    func showAlert(with task: Task? = nil, completion: (() -> Void)? = nil) {
        let alertBuilder = AlertControllerBuilder(
            title: "Save", 
            message: "What do you want to do?"
        )
        
        let alert = alertBuilder
            .addTextField(placeholder: "Enter title", text: task?.title)
            .addTextField(placeholder: "Enter note", text: task?.note)
            .addAction(title: "Save", style: .default) { [unowned self] title, note in
                if let task, let completion {
                    storageManager.updateTask(task, withTitle: title, andNote: note)
                    completion()
                    return
                }
                saveTask(withTitle: title, andNote: note)
            }
            .addAction(title: "Cancel", style: .destructive)
            .build()
        
        present(alert, animated: true)
        
    }

    func saveTask(withTitle title: String, andNote note: String) {
        storageManager.saveTask(title: title, note: note, toTaskTitle: taskTitle) { task in
            let indexPath = IndexPath(row: currentTasks.firstIndex(of: task) ?? 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
}
