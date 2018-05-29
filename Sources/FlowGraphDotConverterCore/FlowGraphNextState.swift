//
//  FlowGraphNextState.swift
//  FlowGraphDotConverter
//
//  Created by yasoshima on 2018/05/25.
//

import Foundation

class FlowGraphNextState {
    enum Kind {
        case run
        case wait
    }
    
    let kind: Kind
    let token: CodeSyntaxToken
    var name: String?
    var comment: String?
    
    init(kind: Kind, token: CodeSyntaxToken) {
        self.kind = kind
        self.token = token
    }
    
    func uiflow() -> String {
        return self.dotText()
    }
    
    func dotText() -> String {
        return self.comment?.dropFirst(2).trimmingCharacters(in: .whitespacesAndNewlines) ?? self.name ?? ""
    }
}
