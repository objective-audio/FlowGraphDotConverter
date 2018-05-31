//
//  FlowGraphState.swift
//  FlowGraphDotConverter
//
//  Created by yasoshima on 2018/05/25.
//

import Foundation

class FlowGraphState {
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
    
    func dotDeclarationText() -> String {
        var labelTexts: [String] = []
        labelTexts.append("\(self.name)")
        
        if let comment = self.comment {
            labelTexts.append("\(comment.dropFirst(2).trimmingCharacters(in: .whitespacesAndNewlines))")
        }

        let label = "{" + labelTexts.joined(separator: "|") + "}"
        
        return Dot.elementText(name: self.name, dictionary: ["shape": "record", "label": label])
    }
    
    func dotActionsText() -> [String] {
        return self.nextStates.filter { $0.kind != .stay }.enumerated().map { (idx, nextState) in
            let nextName = nextState.name ?? "unknown"
            return "\"\(self.name)\" -> \"\(nextName)\"" + nextState.dotElementText()
        }
    }
}
