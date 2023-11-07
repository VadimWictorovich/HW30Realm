//
//  TasksList.swift
//  HW30Realm
//
//  Created by Вадим Игнатенко on 7.11.23.
//

import Foundation
import RealmSwift

class TasksList: Object {
    
    @Persisted var name = ""
    @Persisted var date = Date()
    @Persisted var tasks = List<Task>()
}

