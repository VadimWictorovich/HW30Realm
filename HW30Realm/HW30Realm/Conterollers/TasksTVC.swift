//
//  TasksTVC.swift
//  HW30Realm
//
//  Created by Вадим Игнатенко on 6.11.23.
//

import UIKit
import RealmSwift

enum TasksTVCFlow {
    case addingNewTask
    case editingTask(task: Task)
}

struct TxtAlertData {
    
    let titleForAlert = "Task value"
    var messageForAlert: String
    let doneButtonForAlert: String
    let cancelTxt = "Cancel"
    
    let newTextFieldPlaceholder = "New task"
    let noteTextFieldPlaceholder = "Note"
    
    var taskName: String?
    var taskNote: String?
    
    init(tasksTVCFlow: TasksTVCFlow) {
        switch tasksTVCFlow {
        case .addingNewTask:
            messageForAlert = "Please insert new task value"
            doneButtonForAlert = "Save"
        case .editingTask(let task):
            messageForAlert = "Please edit your task"
            doneButtonForAlert = "Update"
            taskName = task.name
            taskNote = task.note
        }
    }
}

class TasksTVC: UITableViewController {
    
    var tasksList: TasksList?
    private var notCompletedTasks: Results<Task>!
    private var completedTasks: Results<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = tasksList?.name
        filteringTasks()
        longTaped()
        
    }
    
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        alertForAddAndUpdatesTask(tasksTVCFlow: .addingNewTask)
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? notCompletedTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Not comleted tasks" : "Comleted tasks"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = indexPath.section == 0 ? notCompletedTasks[indexPath.row] : completedTasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let task = indexPath.section == 0 ? notCompletedTasks[indexPath.row] : completedTasks[indexPath.row]
        let deleteContextualAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            StorageManager.deleteTask(task: task)
            self?.filteringTasks()
        }
        let editContextualAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, _ in
            self?.alertForAddAndUpdatesTask(tasksTVCFlow: .editingTask(task: task))
        }
        let doneText = task.isCompleted ? "Not done" : "Done"
        let doneContextualAction = UIContextualAction(style: .normal, title: doneText) { [weak self] _, _, _ in
            StorageManager.makeDoneTask(task: task)
            self?.filteringTasks()
        }
    
        doneContextualAction.backgroundColor = .green
        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [doneContextualAction, deleteContextualAction, editContextualAction])
        return swipeActionsConfiguration
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { true }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let task = sourceIndexPath.section == 0 ?
        notCompletedTasks[sourceIndexPath.row] : completedTasks[sourceIndexPath.row]
        StorageManager.makeDoneTask(task: task)
        tableView.setEditing(false, animated: true)
        self.filteringTasks()
    }
    
    private func longTaped() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            tableView.setEditing(true, animated: true)
        }
    }
    
    private func filteringTasks() {
        notCompletedTasks = tasksList?.tasks.filter("isCompleted = false")
        completedTasks = tasksList?.tasks.filter("isCompleted = true")
        tableView.reloadData()
    }
    
    private func alertForAddAndUpdatesTask(tasksTVCFlow: TasksTVCFlow) {
        
        let txtAlertData = TxtAlertData(tasksTVCFlow: tasksTVCFlow)
        
        let alert = UIAlertController(title: txtAlertData.titleForAlert,
                                                message: txtAlertData.messageForAlert,
                                                preferredStyle: .alert)
        
        var taskTextField: UITextField!
        var noteTextField: UITextField!
        
        
        alert.addTextField { textField in
            taskTextField = textField
            taskTextField.placeholder = txtAlertData.newTextFieldPlaceholder
            taskTextField.text = txtAlertData.taskName
        }
        
        alert.addTextField { textField in
            noteTextField = textField
            noteTextField.placeholder = txtAlertData.noteTextFieldPlaceholder
            noteTextField.text = txtAlertData.taskNote
        }
        
        let saveAction = UIAlertAction(title: txtAlertData.doneButtonForAlert, style: .default) { [weak self] _ in
            
            guard let self,
                  let newTaskName = taskTextField.text, !newTaskName.isEmpty,
                  let noteTask = noteTextField.text, !noteTask.isEmpty,
                  let currentTasksList = self.tasksList
            else { return }
            
            switch tasksTVCFlow {
                case .addingNewTask:
                    let task = Task()
                    task.name = newTaskName
                    task.note = noteTask
                    StorageManager.saveTask(tasksList: currentTasksList, newTask: task)
                case .editingTask(let task):
                    StorageManager.editTask(name: newTaskName, note: noteTask, task: task)
            }
            
            self.filteringTasks()
        }
        
        let cancelAction = UIAlertAction(title: txtAlertData.cancelTxt, style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
