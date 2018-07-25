//
//  CodeBase.swift
//

import Foundation

class CodeBase: CustomDebugStringConvertible {
    let address: CodeAddress
    let structure: CodeStructure
    
    init(address: CodeAddress, structure: CodeStructure) {
        self.address = address
        self.structure = structure
    }
    
    var debugDescription: String {
        return "{address: \(self.address)}"
    }
}

class CodeEnum: CodeBase {
    private(set) var caseNames: [String] = []
    
    func add(caseName: String) {
        self.caseNames.append(caseName)
    }
    
    override var debugDescription: String {
        return "{address: \(self.address), caseNames: \(self.caseNames)}"
    }
}

class CodeStruct: CodeBase {
}

class CodeClass: CodeBase {
}

class CodeExtension: CodeBase {
}

class CodeFunction: CodeBase {
}

class CodeExprCall: CodeBase {
    private(set) var arguments: [CodeExprArgument] = []
    
    func add(argument: CodeExprArgument) {
        self.arguments.append(argument)
    }
    
    override var debugDescription: String {
        return "{address: \(self.address), arguments: \(self.arguments)}"
    }
    
    var varName: String? {
        guard let exprCallName = self.address.node?.name else {
            return nil
        }
        
        let components = exprCallName.components(separatedBy: ".")
        
        guard components.count > 1 else {
            return nil
        }
        
        return components[components.count - 2]
    }
}

class CodeExprArgument: CodeBase {
    var brase: CodeBrase?
    
    override var debugDescription: String {
        return "{address: \(self.address), brase: \(self.brase?.debugDescription ?? "nil")}"
    }
}

class CodeBrase: CodeBase {
}

class CodeLocalVar: CodeBase {
}

class CodeInstanceVar: CodeBase {
}

enum CodeVar {
    case local(CodeLocalVar)
    case instance(CodeInstanceVar)
    
    var base: CodeBase {
        switch self {
        case .local(let localVar):
            return localVar as CodeBase
        case .instance(let instanceVar):
            return instanceVar as CodeBase
        }
    }
}
