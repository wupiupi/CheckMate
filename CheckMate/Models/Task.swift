//
//  Task.swift
//  CheckMate
//
//  Created by Paul Makey on 18.02.24.
//

import RealmSwift
import Foundation

final class TaskTitle: Object {
    @Persisted var title = ""
    @Persisted var date = Date()
    @Persisted var tasks = List<Task>()
}

final class Task: Object {
    @Persisted var title = ""
    @Persisted var note = ""
    @Persisted var date = Date()
    @Persisted var isComplete = false
}
