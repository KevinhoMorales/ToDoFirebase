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
        addTask(task: task)
    }
    
    fileprivate func readTasks() {
        getTasks { tasks in
            if tasks.count == 0 {
                print("Not Tasks!")
            } else {
                DispatchQueue.main.async { [self] in
                    tasksTableView.reloadData()
                }
            }
        }
    }
    
    fileprivate func addTask(task: String) {
        db.collection("kfmorales94@gmail.com").document("tasks").setData([
            "task": task], merge: true)
    }
    
    fileprivate func deleteTask() {
        
    }
    
    fileprivate func updateTask() {
        
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = tasksArray[indexPath.row].readTask
        return cell
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

