//
//  StorageManager.swift
//  CheckMate
//
//  Created by Paul Makey on 18.02.24.
//

import RealmSwift

final class StorageManager {
    private let shared = StorageManager()
    
    let realm: Realm
    
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("ERROR: \(error)")
        }
    }
    
    // MARK: - CRUD
    func save(taskTitle: TaskTitle) {
        write {
            realm.add(taskTitle)
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
