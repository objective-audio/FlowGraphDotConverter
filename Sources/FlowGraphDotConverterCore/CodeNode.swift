//
//  CodeType.swift
//

import Foundation
import SourceKittenFramework

enum CodeNodeKind {
    case `class`
    case `struct`
    case `extension`
    case `enum`
    case enumcase
    case enumelement
    case functionMethodInstance
    case exprCall
    case exprArgument
    case brase
    case localVar
    case instanceVar
    
    init?(kind: String?) {
        guard let kind = kind else {
            return nil
        }
        
        switch kind {
        case SwiftDeclarationKind.class.rawValue:
            self = .class
        case SwiftDeclarationKind.struct.rawValue:
            self = .struct
        case SwiftDeclarationKind.extension.rawValue:
            self = .extension
        case SwiftDeclarationKind.enum.rawValue:
            self = .enum
        case SwiftDeclarationKind.enumcase.rawValue:
            self = .enumcase
        case SwiftDeclarationKind.enumelement.rawValue:
            self = .enumelement
        case SwiftDeclarationKind.functionMethodInstance.rawValue:
            self = .functionMethodInstance
        case SwiftExprKind.call.rawValue:
            self = .exprCall
        case SwiftExprKind.argument.rawValue:
            self = .exprArgument
        case StatementKind.brace.rawValue:
            self = .brase
        case SwiftDeclarationKind.varLocal.rawValue:
            self = .localVar
        case SwiftDeclarationKind.varInstance.rawValue:
            self = .instanceVar
        default:
            return nil
        }
    }
}

struct CodeNode {
    let structure: CodeStructure
    let index: Int
    
    init(structure: CodeStructure, index: Int) {
        self.structure = structure
        self.index = index
    }
    
    var rawKind: String { return self.structure.kind ?? "" }
    var kind: CodeNodeKind? { return CodeNodeKind(kind: self.structure.kind) }
    var name: String { return self.structure.name ?? "" }
}

extension CodeNode: CustomDebugStringConvertible {
    var debugDescription: String {
        return "{name:\(self.name), rawKind:\(self.rawKind), index:\(self.index)}"
    }
}

extension CodeNode: Equatable {
    static func == (lhs: CodeNode, rhs: CodeNode) -> Bool {
        return lhs.name == rhs.name && lhs.rawKind == rhs.rawKind && lhs.index == rhs.index
    }
}

struct CodeAddress {
    let nodes: [CodeNode]
    
    var node: CodeNode? {
        return self.nodes.last
    }
    
    init(nodes: [CodeNode]) {
        self.nodes = nodes
    }
    
    func parent() -> CodeAddress? {
        guard self.nodes.count > 0 else {
            return nil
        }
        return CodeAddress(nodes: Array<CodeNode>(self.nodes.dropLast()))
    }
    
    func child(node: CodeNode) -> CodeAddress {
        return CodeAddress(nodes: self.nodes + [node])
    }
    
    func className() -> String? {
        var names: [String] = []
        
        for node in self.nodes {
            if let kind = node.kind, kind == .class || kind == .struct || kind == .extension, !node.name.isEmpty {
                names.append(node.name)
            }
        }
        
        if names.isEmpty {
            return nil
        } else {
            return names.joined(separator: "-")
        }
    }
}

extension CodeAddress: CustomDebugStringConvertible {
    var debugDescription: String {
        return self.nodes.map { $0.debugDescription }.joined(separator: ".")
    }
}

extension CodeAddress: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.debugDescription)
    }
}

extension CodeAddress: Equatable {
    static func == (lhs: CodeAddress, rhs: CodeAddress) -> Bool {
        return lhs.nodes == rhs.nodes
    }
}
