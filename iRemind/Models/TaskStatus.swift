//
//  TaskStatus.swift
//  iRemind
//
//  Created by Lasha Tavberidze on 12.03.25.
//

import SwiftUI

enum TaskStatus: Int, CaseIterable, Identifiable {
    case todo = 0
    case doing = 1
    case done = 2
    
    var id: Int { self.rawValue }
    
    var description: String {
        switch self {
        case .todo: return "To Do"
        case .doing: return "Doing"
        case .done: return "Done"
        }
    }
    
    var color: Color {
        switch self {
        case .todo: return Theme.todoColor
        case .doing: return Theme.doingColor
        case .done: return Theme.doneColor
        }
    }
    
    var icon: String {
        switch self {
        case .todo: return "circle"
        case .doing: return "arrow.triangle.2.circlepath"
        case .done: return "checkmark.circle.fill"
        }
    }
} 