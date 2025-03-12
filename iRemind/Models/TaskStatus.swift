//
//  TaskStatus.swift
//  iRemind
//
//  Created by Lasha Tavberidze on 12.03.25.
//

import Foundation

enum TaskStatus: Int16, Codable, CaseIterable {
    case todo = 0
    case doing = 1
    case done = 2

    var description: String {
        switch self {
        case .todo:
            return "To Do"
        case .doing:
            return "Doing"
        case .done:
            return "Done"
        }
    }
}
