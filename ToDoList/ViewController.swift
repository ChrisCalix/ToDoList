//
//  ViewController.swift
//  ToDoList
//
//  Created by Sonic on 7/3/23.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    var taskList = [TaskEntity]()
    
    
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "Task")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveTask()
        
    }

    @IBAction func addTask(_ sender: Any) {
        var nameTask = UITextField()
        
        let alert = UIAlertController(title: "New", message: "Task", preferredStyle: .alert)
        
        let actionAgree = UIAlertAction(title: "Agree", style: .default) { _ in
            let context = self.persistentContainer.viewContext
            
            let newTask = TaskEntity(context: context)
            newTask.name = nameTask.text
            newTask.isComplete = false
            
            self.taskList.append(newTask)
            
            self.save(context: context)
        }
        
        alert.addTextField { textFieldAlert in
            textFieldAlert.placeholder = "Write your text here..."
            nameTask = textFieldAlert
        }
        
        alert.addAction(actionAgree)
        
        present(alert, animated: true)
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        self.tableView.reloadData()
    }
    
    func retrieveTask() {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        let context = self.persistentContainer.viewContext
        do {
            taskList = try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task = taskList[indexPath.row]
        
        cell.textLabel?.text = task.name
        cell.textLabel?.textColor = task.isComplete ? .black : .blue
        
        cell.detailTextLabel?.text = task.isComplete ? "Done" : "To Do"
        cell.detailTextLabel?.textColor = task.isComplete ? .black : .blue
        
        cell.accessoryType = task.isComplete ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // PAlomear la tarea
        
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = cell.accessoryType == .checkmark ? .none : .checkmark
        }
        taskList[indexPath.row].isComplete.toggle()
        let context = self.persistentContainer.viewContext
        
        save(context: context)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let actionDelete = UIContextualAction(style: .normal, title: "Delete") { _, _, _ in
            let context = self.persistentContainer.viewContext
            context.delete(self.taskList[indexPath.row])
            
            self.taskList.remove(at: indexPath.row)
            
            self.save(context: context)
            }
        return UISwipeActionsConfiguration(actions: [actionDelete])
        }
}
