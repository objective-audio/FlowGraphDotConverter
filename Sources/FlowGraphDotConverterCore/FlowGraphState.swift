//
//  FlowGraphState.swift
//

import Foundation

class FlowGraphState {
    enum Connection {
        case both
        case bothRunInputOnly
        case inputOnly
        case outputOnly
        case alone
        
        func color() -> String {
            switch self {
            case .both:
                return "#AAAAAA"
            case .bothRunInputOnly:
                return "#40C5EE"
            case .inputOnly:
                return "#FF8A00"
            case .outputOnly:
                return "#00D54B"
            case .alone:
                return "#EF34AC"
            }
        }
    }
    
    let name: String
    private(set) var nextStates: [FlowGraphNextState] = []
    let codeExprCall: CodeExprCall
    var comment: String?
    
    var varName: String? {
        guard let exprCallName = self.codeExprCall.address.node?.name else {
            return nil
        }
        
        let components = exprCallName.components(separatedBy: ".")
        
        guard components.count > 1 else {
            return nil
        }
        
        return components[components.count - 2]
    }
    
    init(name: String, codeExprCall: CodeExprCall) {
        self.name = name
        self.codeExprCall = codeExprCall
    }
    
    func add(nextState: FlowGraphNextState) {
        self.nextStates.append(nextState)
    }
    
    func dotDeclarationText(instance: FlowGraphInstance) -> String {
        var labelTexts: [String] = []
        labelTexts.append("\(self.name)")
        
        if let comment = self.comment {
            labelTexts.append("\(comment.dropFirst(2).trimmingCharacters(in: .whitespacesAndNewlines))")
        }

        let label = "{" + labelTexts.joined(separator: "|") + "}"
        
        return Dot.elementText(name: self.name, dictionary: ["shape": "record", "label": label, "color": self.connection(instance: instance).color()])
    }
    
    func dotActionsText() -> [String] {
        return self.nextStates.filter { $0.kind != .stay }.map { nextState in
            let nextName = nextState.name ?? "unknown"
            return "\"\(self.name)\" -> \"\(nextName)\"" + nextState.dotElementText()
        }
    }
    
    func isEnter() -> Bool {
        guard self.name.hasSuffix("Enter") else {
            return false
        }
        
        guard self.nextStates.count == 1 else {
            return false
        }
        
        guard let nextState = self.nextStates.first else {
            return false
        }
        
        guard nextState.kind == .wait else {
            return false
        }
        
        guard let nextStateName = nextState.name, nextStateName == self.name.dropLast(5) else {
            return false
        }
        
        return true
    }
    
    func hasOutput() -> Bool {
        return self.nextStates.filter { $0.kind != .stay }.count > 0
    }
    
    func hasInput(instance: FlowGraphInstance) -> Bool {
        for state in instance.states {
            for nextState in state.nextStates {
                if let nextStateName = nextState.name, nextStateName == self.name {
                    return true
                }
            }
        }
        return false
    }
    
    func hasRunInputOnly(instance: FlowGraphInstance) -> Bool {
        var hasRunOnly: Bool = false
        
        for state in instance.states {
            for nextState in state.nextStates {
                if let nextStateName = nextState.name, nextStateName == self.name {
                    if nextState.kind == .run {
                        hasRunOnly = true
                    } else {
                        return false
                    }
                }
            }
        }
        return hasRunOnly
    }
    
    func connection(instance: FlowGraphInstance) -> Connection {
        let hasOutput = self.hasOutput()
        let hasInput = self.hasInput(instance: instance)
        let hasRunInputOnly = self.hasRunInputOnly(instance: instance)
        
        if hasOutput && hasInput {
            if hasRunInputOnly {
                return .bothRunInputOnly
            } else {
                return .both
            }
        } else if hasOutput {
            return .outputOnly
        } else if hasInput {
            return .inputOnly
        } else {
            return .alone
        }
    }
}
