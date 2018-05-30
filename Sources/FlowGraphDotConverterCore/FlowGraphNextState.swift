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
        
        func styleText() -> String {
            switch self {
            case .run:
                return "solid"
            case .wait:
                return "dashed"
            }
        }
    }
    
    let kind: Kind
    let token: CodeSyntaxToken
    var name: String?
    var comment: String?
    
    init(kind: Kind, token: CodeSyntaxToken) {
        self.kind = kind
        self.token = token
    }
    
    func dotElementText() -> String {
        var attrs: [String: String] = [:]
        
        if let comment = self.comment?.dropFirst(2).trimmingCharacters(in: .whitespacesAndNewlines) {
            attrs["label"] = comment
        }
        
        attrs["style"] = self.kind.styleText()
        
        return Dot.elementText(name: "", dictionary: attrs)
    }
}
