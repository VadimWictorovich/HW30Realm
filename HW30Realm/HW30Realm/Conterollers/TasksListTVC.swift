//
//  TasksListTVC.swift
//  HW30Realm
//
//  Created by Вадим Игнатенко on 6.11.23.
//

import UIKit
import RealmSwift

class TasksListTVC: UITableViewController {
    
    var tasksLists: Results<TasksList>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksLists = StorageManager.getAllTasksLists().sorted(byKeyPath: "name")
    }
    
    
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        alertForAddAndUpdatesListTasks()
    }
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        let sert = sender.selectedSegmentIndex == 0 ? "name" : "date"
        tasksLists = tasksLists.sorted(byKeyPath: sert)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksLists.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let tl = tasksLists[indexPath.row]
        cell.configure(with: tl)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let list = tasksLists[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, _ in
            StorageManager.deleteTasksList(tasksList: list)
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, _ in
            self?.alertForAddAndUpdatesListTasks(currentList: list, indexPath: indexPath)
        }
        let doneAllAction = UIContextualAction(style: .normal, title: "All Done") { [weak self] _, _, _ in
            StorageManager.makeAllDone(tasksList: list)
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        doneAllAction.backgroundColor = .green
        let swipeActionsConfiguration = UISwipeActionsConfiguration(actions: [doneAllAction,deleteAction,editAction])
        return swipeActionsConfiguration
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = sb.instantiateViewController(withIdentifier: "TasksTVC") as? TasksTVC else { return }
        vc.tasksList = tasksLists[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func alertForAddAndUpdatesListTasks(currentList: TasksList? = nil, indexPath: IndexPath? = nil) {
        
        let title = currentList == nil ? "New list" : "Edit List"
        let messege = "Please insert list name"
        let doneButtonName = currentList == nil ? "Save" : "Update"
        let alertController = UIAlertController(title: title, message: messege, preferredStyle: .alert)
        var alertTextField: UITextField!
        let saveAction = UIAlertAction(title: doneButtonName, style: .default) { [weak self] _ in
            
            guard let self,
                  let newListName = alertTextField.text,
                  !newListName.isEmpty else { return }
            
            if let currentList = currentList,
               let indexPath = indexPath {
                StorageManager.editTasksList(newListName: newListName, tasksList: currentList)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            } else {
                let taskList = TasksList()
                taskList.name = newListName
                StorageManager.saveTasksList(newTasksList: taskList)
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        alertController.addTextField { textField in
            alertTextField = textField
            alertTextField.text = currentList?.name
            alertTextField.placeholder = "List name"
        }
        
        present(alertController, animated: true)
    }
    
    
}
