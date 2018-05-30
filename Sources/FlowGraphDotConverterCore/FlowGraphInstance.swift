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
    
    func dotText() -> String {
        var texts: [String] = []
        
        texts.append(Dot.elementText(name: "graph", dictionary: ["charset": "UTF-8", "rankdir": "TB"]))
        texts.append(Dot.elementText(name: "node", dictionary: ["style": "solid,filled", "fontsize": "10", "fontname": "Osaka-Mono", "color": "#CCCCCC", "fillcolor": "#F9F9F9", "fontcolor": "#333333"]))
        texts.append(Dot.elementText(name: "edge", dictionary: ["fontsize": "9", "color": "#AAAAAA", "fontname": "Osaka-Mono", "fontcolor": "#333333"]))
        texts = texts + [""]
        texts = texts + self.states.map { $0.dotDeclarationText() }
        texts = texts + [""]
        texts = texts + self.states.flatMap { $0.dotActionsText() }
        
        return Dot.digraphText(texts)
    }
}
