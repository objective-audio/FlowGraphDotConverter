//
//  FlowGraphInstance.swift
//  FlowGraphDotConverter
//
//  Created by yasoshima on 2018/05/25.
//

import Foundation

class FlowGraphInstance {
    let codeVar: CodeVar
    
    init(codeVar: CodeVar) {
        self.codeVar = codeVar
    }
    
    private(set) var states: [FlowGraphState] = []
    
    func add(state: FlowGraphState) {
        self.states.append(state)
    }
    
    func uiflow() -> String {
        return self.states.map { $0.uiflow() }.joined(separator: "\n\n")
    }
    
    func dotText() -> String {
        var texts: [String] = []
        
        texts.append(Dot.elementText(name: "graph", dictionary: ["charset": "UTF-8", "labelloc": "t", "labeljust": "r", "style": "filled", "margin": "0.2", "ranksep": "0.5", "nodesep": "0.4", "rankdir": "LR"]))
        texts.append(Dot.elementText(name: "node", dictionary: ["style": "solid", "fontsize": "11", "margin": "0.1,0.1", "fontname": "HiraKakuProN-W3"]))
        texts.append(Dot.elementText(name: "edge", dictionary: ["fontsize": "9", "color": "#777777", "fontname": "HiraKakuProN-W3"]))
        texts = texts + [""]
        texts = texts + self.states.map { $0.dotDeclarationText() }
        texts = texts + [""]
        texts = texts + self.states.flatMap { $0.dotActionsText() }
        
        return Dot.digraphText(texts)
    }
}
