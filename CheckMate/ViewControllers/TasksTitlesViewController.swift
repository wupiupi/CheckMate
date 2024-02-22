//
//  TasksTitlesViewController.swift
//  CheckMate
//
//  Created by Paul Makey on 18.02.24.
//

import UIKit
import RealmSwift

final class TasksTitlesViewController: UITableViewController {
    
    // MARK: - Private properties
    private var taskTitles: Results<TaskTitle>!
    private let storageManager = StorageManager.shared
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonDidTapped)
        )
        navigationItem.leftBarButtonItem = editButtonItem
        
        taskTitles = storageManager.fetchTasksTitles(TaskTitle.self)
            .sorted(byKeyPath: "date", ascending: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let tasksVC = segue.destination as? TasksViewController,
              let indexPath = tableView.indexPathForSelectedRow else { return }
        tasksVC.taskTitle = taskTitles[indexPath.row]
    }
    
    // MARK: - IB Actions
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        taskTitles = sender.selectedSegmentIndex == 0
        ? taskTitles.sorted(byKeyPath: "date", ascending: false)
        : taskTitles.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    @objc func addButtonDidTapped() {
        showAlertController()
    }
}

// MARK: - UITableViewDataSource
extension TasksTitlesViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        taskTitles.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TaskTitleCell",
            for: indexPath
        )
        
        let taskTitle = taskTitles[indexPath.row]
        let currentTasks = taskTitle.tasks.filter("isComplete = false")
        
        var content = cell.defaultContentConfiguration()
        content.text = taskTitle.title
        
        if currentTasks.count == 0 {
            cell.accessoryType = .checkmark
        } else {
            content.secondaryText = currentTasks.count.formatted()
            cell.accessoryType = .none
        }
        
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TasksTitlesViewController {
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let taskTitle = taskTitles[indexPath.row]
        
        let doneAction = UIContextualAction(
            style: .normal,
            title: "Done") { [unowned self] _, _, _ in
                storageManager.done(for: taskTitle)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit") { [unowned self] _, _, _ in
                showAlertController(withTitle: taskTitle) {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete") { [unowned storageManager] _, _, _ in
                storageManager.delete(taskTitle: taskTitle)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        
        doneAction.backgroundColor = .systemGreen
        editAction.backgroundColor = .systemOrange
        
        return UISwipeActionsConfiguration(
            actions: [
                doneAction,
                editAction,
                deleteAction
            ]
        )
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - AlertController
private extension TasksTitlesViewController {
    func showAlertController(withTitle taskTitle: TaskTitle? = nil, completion: (() -> Void)? = nil) {
        let alertBuilder = AlertControllerBuilder(
            title: taskTitle == nil ? "New task" : "Edit task title",
            message: "Set a title for a new task:"
        )
        
        let alertController = alertBuilder
            .addTextField(placeholder: "Name your task:", text: taskTitle?.title)
        
            .addAction(
                title: taskTitle == nil ? "Save" : "Edit",
                style: .default,
                handler: {
                    [unowned self] newTitle,
                    _ in
                    if let taskTitle,
                       let completion {
                        storageManager.update(oldValue: taskTitle, newTitle: newTitle)
                        completion()
                        return
                    }
                    
                    storageManager.save(title: newTitle) { taskTitle in
                        let indexPath = IndexPath(
                            row: taskTitles.firstIndex(of: taskTitle) ?? 0,
                            section: 0
                        )
                        tableView.insertRows(at: [indexPath], with: .automatic)
                    }
                })
        
            .addAction(title: "Cancel", style: .destructive)
            .build()
        
        present(alertController, animated: true)
    }
}
