//
//  Task.swift
//  ToDoFirebase
//
//  Created by Kevin Morales on 12/17/21.
//

import Foundation

class TaskModel: NSObject {
    fileprivate let task = "task"
    fileprivate let id = "id"
    
    var readTask: String?
    var readId: String?

    func setMap(valores: [String:Any]) {
        readTask = valores[task] as? String
        readId = valores[id] as? String
    }
    
    func getMap() -> [String:Any] {
        return [
            task: readTask as Any,
            id: readId as Any
        ]
    }
}
