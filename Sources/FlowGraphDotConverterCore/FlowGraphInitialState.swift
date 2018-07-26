//
//  FlowGraphInitialState.swift
//

import Foundation

class FlowGraphInitialState {
    let name: String
    let codeExprCall: CodeExprCall
    
    init(name: String, codeExprCall: CodeExprCall) {
        self.codeExprCall = codeExprCall
        self.name = name
    }
    
    var varName: String? {
        return self.codeExprCall.varName
    }
}
