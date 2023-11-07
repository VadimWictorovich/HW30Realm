//
//  StorageManager.swift
//  HW30Realm
//
//  Created by Вадим Игнатенко on 6.11.23.
//

import Foundation
import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    
    // MARK: - TasksList
    
    static func getAllTasksLists () -> Results<TasksList> {
        realm.objects(TasksList.self)
    }
    
    static func saveTasksList(newTasksList: TasksList) {
        do {
            try realm.write {
                realm.add(newTasksList)
            }
        } catch {
            print("saveTasksList error: \(error)")
        }
    }
    
    static func editTasksList(newListName: String, tasksList: TasksList) {
        do {
            try realm.write {
                tasksList.name = newListName
            }
        } catch {
            print("editTasksList error: \(error)")
        }
    }
    
    static func deleteTasksList(tasksList: TasksList) {
        do {
            try realm.write {
                let tasks = tasksList.tasks
                realm.delete(tasks)
                realm.delete(tasksList)
            }
        } catch {
            print("deleteTasksList error: \(error)")
        }
    }
    
    
    // MARK: - Task
    
    static func makeAllDone (tasksList: TasksList) {
        do {
            try realm.write {
                tasksList.tasks.setValue(true, forKey: "isCompleted")
            }
        } catch {
            print("makeAllDone error: \(error)")
        }
    }
    
    static func saveTask(tasksList: TasksList, newTask: Task) {
        do {
            try realm.write {
                tasksList.tasks.append(newTask)
            }
        } catch {
            print("saveTask error: \(error)")
        }
    }
    
    static func editTask(name: String, note: String, task: Task) {
        do {
            try realm.write {
                task.name = name
                task.note = note
            }
        } catch {
            print("editTask error: \(error)")
        }
    }
    
    static func deleteTask(task: Task) {
        do {
            try realm.write {
                realm.delete(task)
            }
        } catch {
            print("deleteTask error: \(error)")
        }
    }
    
    static func makeDoneTask(task: Task) {
        do {
            try realm.write {
                task.isCompleted.toggle()
            }
        } catch {
            print("deleteTask error: \(error)")
        }
    }
    
    // MARK: - Other

    static func deleteAll() {
        do {
            try realm.write{
                realm.deleteAll()
            }
        } catch {
            print("deleteAll error: \(error)")
        }
    }
    
    static func findRealmFile() {
        print("Realm is located at:", realm.configuration.fileURL!)
    }
}
