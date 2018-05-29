//
//  CodeSyntaxMap.swift
//  SPMTest
//
//  Created by yasoshima on 2018/05/17.
//

import Foundation
import SourceKittenFramework

class CodeSyntaxToken {
    let token: SyntaxToken
    var kind: SyntaxKind { return SyntaxKind(rawValue: self.token.type)! }
    var offset: Int { return self.token.offset }
    var length: Int { return self.token.length }
    let content: String
    
    init(token: SyntaxToken, contents: String) {
        self.token = token
        
        let utf8contents = contents.utf8
        let startIndex = utf8contents.index(utf8contents.startIndex, offsetBy: token.offset)
        let endIndex = utf8contents.index(startIndex, offsetBy: token.length)
        self.content = String(utf8contents[startIndex..<endIndex])!
    }
}

extension CodeSyntaxToken: CustomDebugStringConvertible {
    var debugDescription: String {
        return "{type:\(self.kind) offset:\(self.offset), length:\(self.length), content:'\(self.content)'}"
    }
}

class CodeSyntaxMap {
    var tokens: [CodeSyntaxToken]
    
    init(syntaxMap: SyntaxMap, contents: String) {
        var tokens: [CodeSyntaxToken] = []
        
        syntaxMap.tokens.forEach { token in
            tokens.append(CodeSyntaxToken(token: token, contents: contents))
        }
        
        self.tokens = tokens
    }
    
    func tokensInRange(offset: Int, length: Int) -> [CodeSyntaxToken] {
        return self.tokens.filter { (token) -> Bool in
            return offset <= token.offset && (token.offset + token.length) <= (offset + length)
        }
    }
    
    func tokenBefore(offset: Int) -> CodeSyntaxToken? {
        for token in self.tokens.reversed() {
            if token.offset < offset {
                return token
            }
        }
        return nil
    }
}

extension CodeSyntaxMap: CustomDebugStringConvertible {
    var debugDescription: String {
        return tokens.map { $0.debugDescription }.joined(separator: ",\n")
    }
}
