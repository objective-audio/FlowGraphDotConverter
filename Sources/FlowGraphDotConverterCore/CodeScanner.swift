//
//  CodeScanner.swift
//

import Foundation
import SourceKittenFramework

class CodeScanner {
    private(set) var codeClasses: [CodeAddress: CodeClass] = [:]
    private(set) var codeStructs: [CodeAddress: CodeStruct] = [:]
    private(set) var codeEnums: [CodeAddress: CodeEnum] = [:]
    private(set) var codeFunctions: [CodeAddress: CodeFunction] = [:]
    private(set) var codeExprCalls: [CodeAddress: CodeExprCall] = [:]
    private(set) var codeExprArguments: [CodeAddress: CodeExprArgument] = [:]
    private(set) var codeVars: [CodeAddress: CodeVar] = [:]
    
    init(structure: CodeStructure) {
        self.scan(structure: structure, address: CodeAddress(nodes: []), index: 0)
    }
    
    func scan(structure: CodeStructure, address parentAddress: CodeAddress, index: Int) {
        let node = CodeNode(structure: structure, index: index)
        
        let address = parentAddress.child(node: node)
        
        if let kind = node.kind {
            switch kind {
            case .class:
                self.codeClasses[address] = CodeClass(address: address, structure: structure)
            case .struct:
                self.codeStructs[address] = CodeStruct(address: address, structure: structure)
            case .enum:
                self.codeEnums[address] = CodeEnum(address: address, structure: structure)
            case .enumcase:
                break
            case .enumelement:
                guard let codeEnumAddress = address.parent()?.parent() else {
                    fatalError()
                }
                
                guard let codeEnum = self.codeEnums[codeEnumAddress] else {
                    fatalError()
                }
                
                codeEnum.add(caseName: node.name)
            case .functionMethodInstance:
                self.codeFunctions[address] = CodeFunction(address: address, structure: structure)
            case .exprCall:
                self.codeExprCalls[address] = CodeExprCall(address: address, structure: structure)
            case .exprArgument:
                let argument = CodeExprArgument(address: address, structure: structure)
                
                self.codeExprArguments[address] = argument
                
                guard let exprCallAddress = address.parent() else {
                    fatalError()
                }
                
                guard let codeExprCall = self.codeExprCalls[exprCallAddress] else {
                    break
                }
                
                codeExprCall.add(argument: argument)
            case .brase:
                guard let exprArgAddress = address.parent() else {
                    fatalError()
                }
                
                guard let exprArg = self.codeExprArguments[exprArgAddress] else {
                    break
                }
                
                guard exprArg.brase == nil else {
                    fatalError()
                }
                
                exprArg.brase = CodeBrase(address: address, structure: structure)
            case .localVar:
                self.codeVars[address] = .local(CodeLocalVar(address: address, structure: structure))
            case .instanceVar:
                self.codeVars[address] = .instance(CodeInstanceVar(address: address, structure: structure))
            }
        }
        
        for (index, subStructure) in structure.subStructures.enumerated() {
            self.scan(structure: subStructure, address: address, index: index)
        }
    }
}
