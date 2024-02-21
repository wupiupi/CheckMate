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
    
    // MARK: - CRUD
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
            realm.delete(taskTitle)
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
}
