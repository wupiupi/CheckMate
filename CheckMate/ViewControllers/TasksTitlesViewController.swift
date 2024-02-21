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
    private let storageManager = StorageManager.shared
    private var taskTitles: Results<TaskTitle>!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTitles = storageManager.fetchTasksTitles(TaskTitle.self)
            .sorted(byKeyPath: "date", ascending: false)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonDidTapped)
        )
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

// MARK: - Private Methods
private extension TasksTitlesViewController {
    func showAlertController() {
        let alertBuilder = AlertControllerBuilder(
            title: "New task",
            message: "What do you wanna do?"
        )
        
        let alertController = alertBuilder
            .addTextField(text: "", placeholder: "Type something...")
            .addAction(title: "Save", style: .default)
            .addAction(title: "Cancel", style: .destructive)
            .build()
        
        present(alertController, animated: true)
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
        
        var content = cell.defaultContentConfiguration()
        content.text = taskTitle.title
        content.secondaryText = taskTitle.tasks.count.formatted()
        
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
            title: "Done") { _, _, _ in
                // TODO: - Done method in the StorageManager
                print("DEBUG_PRINT: done button did tapped")
            }
        
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit") { [unowned self] _, _, _ in
                showAlertController()
                storageManager.update(oldValue: taskTitle, newTitle: "asd")
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
}
