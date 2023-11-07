//
//  TaskModel.swift
//  HW30Realm
//
//  Created by Вадим Игнатенко on 7.11.23.
//

import Foundation
import RealmSwift

class Task: Object {
    
    @Persisted var name = ""
    @Persisted var note = ""
    @Persisted var isCompleted = false
    @Persisted var date = Date()
}
