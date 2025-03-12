//
//  Theme.swift
//  iRemind
//
//  Created by Lasha Tavberidze on 12.03.25.
//

import SwiftUI

enum Theme {
    static let primary = Color.accentColor
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let text = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let todoColor = Color.blue
    static let doingColor = Color.orange
    static let doneColor = Color.green
    static let destructive = Color.red
}

struct TaskRowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 8)
            .background(Theme.background)
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Theme.secondaryBackground)
            .cornerRadius(12)
            .shadow(radius: 2)
    }
} 