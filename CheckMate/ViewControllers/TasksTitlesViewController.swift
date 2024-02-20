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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonDidTapped)
        )
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
