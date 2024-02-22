//
//  StorageManager.swift
//  CheckMate
//
//  Created by Paul Makey on 18.02.24.
//

import RealmSwift
import Foundation

final class StorageManager {
    static let shared = StorageManager()
    
    private let realm: Realm
    
    private init() {
        if let realmURL = Realm.Configuration.defaultConfiguration.fileURL {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let fileURL = documentDirectory?.appendingPathComponent(realmURL.lastPathComponent)
            print("Realm file URL: \(fileURL?.path ?? "")")
        }
        
        do {
            realm = try Realm()
        } catch {
            fatalError("ERROR: \(error)")
        }
    }
    
    // MARK: - CRUD for TaskTitles
    func save(title: String, handler: (TaskTitle) -> Void) {
        write {
            let taskTitle = TaskTitle()
            taskTitle.title = title
            realm.add(taskTitle)
            handler(taskTitle)
        }
    }
    
    func fetchTasksTitles<T>(_ type: T.Type) -> Results<T> where T: RealmFetchable {
        realm.objects(T.self)
    }
    
    func update(oldValue: TaskTitle, newTitle: String) {
        write {
            oldValue.title = newTitle
        }
    }
    
    func delete(taskTitle: TaskTitle) {
        write {
            realm.delete(taskTitle.tasks)
            realm.delete(taskTitle)
        }
    }
    
    func done(for taskTitle: TaskTitle) {
        write {
            taskTitle.tasks.forEach { task in
                task.isComplete = true
            }
        }
    }
    
    func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch {
            print(error)
        }
    }
    
    // MARK: - Tasks
    func saveTask(title: String, note: String?, toTaskTitle taskTitle: TaskTitle, completion: (Task) -> Void) {
        write {
            let task = Task(value: [title, note])
            taskTitle.tasks.append(task)
            completion(task)
        }
    }
    
    func updateTask(_ task: Task, withTitle title: String, andNote note: String) {
        write {
            task.title = title
            task.note = note
        }
    }
    
    func deleteTask(_ task: Task) {
        write {
            realm.delete(task)
        }
    }
    
    func done(forTask task: Task) {
        write {
            task.isComplete.toggle()
        }
    }
}
