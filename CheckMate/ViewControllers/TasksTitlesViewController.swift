//
//  TasksTitlesViewController.swift
//  CheckMate
//
//  Created by Paul Makey on 18.02.24.
//

import UIKit
import RealmSwift

final class TasksTitlesViewController: UITableViewController {

    private let storageManager = StorageManager.shared
    private var taskTitles: Results<TaskTitle>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTitles = storageManager.fetchTasksTitles(TaskTitle.self)
    }

}

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
