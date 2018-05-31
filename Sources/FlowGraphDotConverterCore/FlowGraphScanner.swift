//
//  FlowGraphScanner.swift
//

import Foundation
import SourceKittenFramework
import FlowGraph

class StateScanner {
    enum State {
        case findStateDecl
        case findStateName
        case findInDecl
        case findInNextStateKind
        case findReturnDecl
        case findNextStateKind
        case findNextStateName
        case recordNextState
        case failed
    }
    
    typealias Event = (scanner: StateScanner, token: CodeSyntaxToken, codeExprCall: CodeExprCall)
    
    let graph: FlowGraph<State, Event>
    
    var flowGraphState: FlowGraphState?
    
    init() {
        let builder = FlowGraphBuilder<State, Event>()
        
        var tempNextState: FlowGraphNextState?
        
        // stateかどうかを調べる
        builder.add(state: .findStateDecl) { event in
            if event.token.content == "state" {
                // stateだった
                return .wait(.findStateName)
            }
            // stateじゃない
            return .wait(.failed)
        }
        
        // ステートの名前を記録
        builder.add(state: .findStateName) { event in
            event.scanner.flowGraphState = FlowGraphState(name: event.token.content, codeExprCall: event.codeExprCall)
            return .wait(.findInDecl)
        }
        
        // inを探す
        builder.add(state: .findInDecl) { event in
            if event.token.content == "in" {
                // inが見つかった
                return .wait(.findInNextStateKind)
            }
            return .stay
        }
        
        // inの後を調べる
        builder.add(state: .findInNextStateKind) { event in
            switch event.token.content {
            case "run":
                tempNextState = FlowGraphNextState(kind: .run, token: event.token)
                // run
                return .wait(.findNextStateName)
            case "wait":
                tempNextState = FlowGraphNextState(kind: .wait, token: event.token)
                // wait
                return .wait(.findNextStateName)
            case "stay":
                tempNextState = FlowGraphNextState(kind: .stay, token: event.token)
                // stay
                return .run(.recordNextState, event)
            case "return":
                // return
                return .wait(.findNextStateKind)
            default:
                // どれでもない
                return .wait(.findReturnDecl)
            }
        }
        
        // returnを探す
        builder.add(state: .findReturnDecl) { event in
            if event.token.content == "return" {
                // returnが見つかった
                return .wait(.findNextStateKind)
            }
            return .stay
        }
        
        // returnの後を調べる
        builder.add(state: .findNextStateKind) { event in
            switch event.token.content {
            case "run":
                tempNextState = FlowGraphNextState(kind: .run, token: event.token)
                // run
                return .wait(.findNextStateName)
            case "wait":
                tempNextState = FlowGraphNextState(kind: .wait, token: event.token)
                // wait
                return .wait(.findNextStateName)
            case "stay":
                tempNextState = FlowGraphNextState(kind: .stay, token: event.token)
                // stay
                return .run(.recordNextState, event)
            default:
                // どれでもない
                return .wait(.failed)
            }
        }
        
        // 次ステートの名前を保持
        builder.add(state: .findNextStateName) { event in
            if let nextState = tempNextState {
                nextState.name = event.token.content
            }
            return .run(.recordNextState, event)
        }
        
        // 次ステートを記録する
        builder.add(state: .recordNextState) { event in
            if let state = event.scanner.flowGraphState, let nextState = tempNextState {
                state.add(nextState: nextState)
                tempNextState = nil
                // 次ステートを記録した
                return .wait(.findReturnDecl)
            } else {
                // 次ステートを記録できない
                return .wait(.failed)
            }
        }
        
        // スキャン失敗
        builder.add(state: .failed) { event in
            return .stay
        }
        
        self.graph = builder.build(initial: .findStateDecl)
    }
    
    func input(tokens: [CodeSyntaxToken], codeExprCall: CodeExprCall) {
        for token in tokens {
            self.input(token: token, codeExprCall: codeExprCall)
            
            if self.graph.state == .failed {
                return
            }
        }
    }
    
    func input(token: CodeSyntaxToken, codeExprCall: CodeExprCall) {
        self.graph.run((self, token, codeExprCall))
    }
}

class FlowGraphScanner {
    private(set) var flowGraphInstances: [CodeAddress: FlowGraphInstance] = [:]
    private(set) var flowGraphStates: [FlowGraphState] = []
    private(set) var builderVars: [CodeVar] = []
    
    init?(url: URL) {
        guard let file = File(path: url.path) else {
            print("make file failed.\n\(url.path)")
            return nil
        }
        
        guard let structure = try? Structure(file: file) else {
            print("make structure failed.")
            return nil
        }
        
        guard let syntaxMap = try? SyntaxMap(file: file) else {
            print("make syntaxMap failed.")
            return nil
        }
        
        let codeStructure = CodeStructure(structure: structure.dictionary, contents: file.contents)
        let codeSyntaxMap = CodeSyntaxMap(syntaxMap: syntaxMap, contents: file.contents)
        let codeScanner = CodeScanner(structure: codeStructure)
        
        for (_, codeExprCall) in codeScanner.codeExprCalls {
            self.scanState(codeExprCall: codeExprCall, codeSyntaxMap: codeSyntaxMap)
            self.scanBuilder(codeExprCall: codeExprCall, codeScanner: codeScanner)
        }
        
        self.scanInstance()
    }
    
    private func scanState(codeExprCall: CodeExprCall, codeSyntaxMap: CodeSyntaxMap) {
        guard let name = codeExprCall.structure.name, name.hasSuffix(".add") else {
            return
        }
        
        guard codeExprCall.arguments.count == 2 else {
            return
        }
        
        guard let arg = codeExprCall.arguments.first, let argName = arg.structure.name, argName == "state" else {
            return
        }
        
        let splited = name.split(separator: ".")
        
        guard splited.count == 2 else {
            return
        }
        
        guard let bodyOffset = codeExprCall.structure.bodyOffset, let bodyLength = codeExprCall.structure.bodyLength else {
            return
        }
        
        let tokens = codeSyntaxMap.tokensInRange(offset: Int(bodyOffset), length: Int(bodyLength))
        let stateScanner = StateScanner()
        stateScanner.input(tokens: tokens, codeExprCall: codeExprCall)
        
        guard let state = stateScanner.flowGraphState else {
            return
        }
        
        self.flowGraphStates.append(state)
        
        // コメントを追加する
        
        guard let offset = codeExprCall.structure.offset else {
            return
        }
        
        if let commentToken = codeSyntaxMap.tokenBefore(offset: Int(offset)), commentToken.kind == .comment {
            state.comment = commentToken.content
        }
        
        for nextState in state.nextStates {
            let tokenOffset = nextState.token.offset
            
            let prevToken: CodeSyntaxToken? = codeSyntaxMap.tokenBefore(offset: tokenOffset)
            
            if let prevToken = prevToken {
                if prevToken.kind == .comment {
                    nextState.comment = prevToken.content
                    continue
                } else if prevToken.content == "return" {
                    if let prevPrevToken = codeSyntaxMap.tokenBefore(offset: prevToken.offset), prevPrevToken.kind == .comment {
                        nextState.comment = prevPrevToken.content
                    }
                }
            }
        }
    }
    
    private func scanBuilder(codeExprCall: CodeExprCall, codeScanner: CodeScanner) {
        guard let name = codeExprCall.structure.name, name.hasPrefix("FlowGraphBuilder<") else {
            return
        }
        
        guard let node = codeExprCall.address.node, node.index > 0 else {
            return
        }
        
        let expectedVarIndex = node.index - 1
        
        guard let exprCallParent = codeExprCall.address.parent() else {
            return
        }
        
        for (key, value) in codeScanner.codeVars {
            guard let localVarParent = key.parent() else {
                continue
            }
            
            guard localVarParent == exprCallParent else {
                continue
            }
            
            guard let localVarIndex = key.node?.index, localVarIndex == expectedVarIndex else {
                continue
            }
            
            self.builderVars.append(value)
        }
    }
    
    private func scanInstance() {
        for codeVar in self.builderVars {
            self.flowGraphInstances[codeVar.base.address] = FlowGraphInstance(codeVar: codeVar)
        }
        
        
        forStates: for state in self.flowGraphStates {
            guard let stateParent = state.codeExprCall.address.parent() else {
                continue
            }
            
            guard let expectedVarName = state.varName else {
                continue
            }
            
            forVars: for codeVar in self.builderVars {
                guard let varParent = codeVar.base.address.parent() else {
                    continue
                }
                
                switch codeVar {
                case .local:
                    guard stateParent == varParent else {
                        continue forVars
                    }
                case .instance:
                    var stateAncestor: CodeAddress? = stateParent
                    while let ancestor = stateAncestor, ancestor != varParent {
                        stateAncestor = ancestor.parent()
                    }
                    
                    guard stateAncestor != nil else {
                        continue forVars
                    }
                }
                
                guard let varName = codeVar.base.structure.name else {
                    continue
                }
                
                guard varName == expectedVarName else {
                    continue
                }
                
                guard let flowGraphInstance = self.flowGraphInstances[codeVar.base.address] else {
                    continue
                }
                
                flowGraphInstance.add(state: state)
                
                continue forStates
            }
        }
    }
    
    func enterRemovedInstances() -> [CodeAddress: FlowGraphInstance] {
        var dstInstances: [CodeAddress: FlowGraphInstance] = [:]
        
        for (address, srcInstance) in self.flowGraphInstances {
            let dstInstance = FlowGraphInstance(codeVar: srcInstance.codeVar)
            dstInstances[address] = dstInstance
            
            let enterStates = srcInstance.states.filter { $0.isEnter() }
            let notEnterStates = srcInstance.states.filter { !$0.isEnter() }
            
            for srcState in notEnterStates {
                let dstState = FlowGraphState(name: srcState.name, codeExprCall: srcState.codeExprCall)
                dstState.comment = srcState.comment
                
                for srcNextState in srcState.nextStates {
                    if srcNextState.mayBeEnter(), let nextStateName = srcNextState.name, !enterStates.filter({ $0.name == nextStateName }).isEmpty {
                        let dstNextState = FlowGraphNextState(kind: .wait, token: srcNextState.token)
                        dstNextState.comment = srcNextState.comment
                        dstNextState.name = srcNextState.enteredStateName()
                        dstState.add(nextState: dstNextState)
                    } else {
                        dstState.add(nextState: srcNextState)
                    }
                }
                
                dstInstance.add(state: dstState)
            }
        }
        
        return dstInstances
    }
}
