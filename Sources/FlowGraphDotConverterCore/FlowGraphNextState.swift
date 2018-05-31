//
//  FlowGraphNextState.swift
//

import Foundation

class FlowGraphNextState {
    enum Kind {
        case run
        case wait
        case stay
        
        func styleText() -> String {
            switch self {
            case .run:
                return "solid"
            case .wait:
                return "dashed"
            case .stay:
                fatalError()
            }
        }
        
        func color() -> String {
            switch self {
            case .run:
                return "#99DEF3"
            case .wait:
                return "#AAAAAA"
            case .stay:
                fatalError()
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
        attrs["color"] = self.kind.color()
        
        return Dot.elementText(name: "", dictionary: attrs)
    }
    
    func mayBeEnter() -> Bool {
        guard self.kind == .run else {
            return false
        }
        
        guard let name = self.name, name.hasSuffix("Enter") else {
            return false
        }
        
        return true
    }
    
    func enteredStateName() -> String {
        guard mayBeEnter() else {
            fatalError()
        }
        
        guard let name = self.name else {
            fatalError()
        }
        
        return String(name.dropLast(5))
    }
}
