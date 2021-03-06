//
//  ViewController.swift
//  ToDoFirebase
//
//  Created by Kevin Morales on 12/17/21.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController {
    
    @IBOutlet weak var addTextField: UITextField!
    @IBOutlet weak var tasksTableView: UITableView!
    
    fileprivate let db = Firestore.firestore()
    fileprivate var tasksArray = [TaskModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpButtonsNavigation()
        // Do any additional setup after loading the view.
    }
    
    fileprivate func setUpView() {
        setUpButtonsNavigation()
        readTasks()
    }
    
    fileprivate func setUpButtonsNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
    }
    
    @objc
    func addTapped() {
        guard let task = addTextField.text else {return}
        if task.isEmpty {
            showAlert(message: "Agregue una tarea por favor")
        } else {
            let id = Int.random(in: 0..<1000000)
            let taskModel = TaskModel()
            taskModel.readTask = task
            taskModel.readId = "\(id)"
            addTask(task: taskModel)
            addTextField.text = ""
        }
    }
    
    fileprivate func readTasks() {
        tasksArray.removeAll()
        getTasks { [self] tasks in
            if tasks.count == 0 {
                print("Not Tasks!")
                tasksTableView.isHidden = true
            } else {
                tasksTableView.isHidden = false
                DispatchQueue.main.async { [self] in
                    tasksTableView.reloadData()
                }
            }
        }
    }
    
    fileprivate func addTask(task: TaskModel) {
        db.collection("kfmorales94@gmail.com").document(task.readId!).setData([
            "task": task.readTask!, "id": task.readId!], merge: true)
        readTasks()
    }
    
    fileprivate func deleteTask(task: TaskModel) {
        db.collection("kfmorales94@gmail.com").document(task.readId!).delete()
        readTasks()
    }
    
    fileprivate func updateTask(task: TaskModel, newText: String) {
        db.collection("kfmorales94@gmail.com").document(task.readId!).setData([
            "task": newText], merge: true)
        readTasks()
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        let task = tasksArray[indexPath.row]
        cell.textLabel?.text = task.readTask
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasksArray[indexPath.row]
        showInputDialog(title: "La tarea \(task.readTask)", subtitle: nil, actionTitle: "Editar", cancelTitle: "Cancelar", inputPlaceholder: task.readTask, inputKeyboardType: .default) { _ in
            print("Cancel")
        } actionHandler: { [self] text in
            updateTask(task: task, newText: text!)
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let task = tasksArray[indexPath.row]
            deleteTask(task: task)
        }
    }
}

extension ViewController {
    public func getTasks(completionHandler:@escaping([TaskModel])->()) {
        db.collection("kfmorales94@gmail.com").getDocuments() { [self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let adsData = TaskModel()
                    adsData.setMap(valores: document.data())
                    tasksArray.append(adsData)
                }
                completionHandler(tasksArray)
            }
        }
    }
}


extension ViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func showAlert(message: String) {
        let alert = UIAlertController(title: "Aviso", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
