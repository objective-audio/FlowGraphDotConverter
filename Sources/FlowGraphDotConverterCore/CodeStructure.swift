//
//  CodeStructure.swift
//  SPMTest
//
//  Created by yasoshima on 2018/05/11.
//

import Foundation
import SourceKittenFramework

class CodeStructure {
    let kind: String?
    let name: String?
    let typeName: String?
    let offset: Int64?
    let length: Int64?
    let nameOffset: Int64?
    let nameLength: Int64?
    let bodyOffset: Int64?
    let bodyLength: Int64?
    let body: String?
    let content: String?
    let indent: Int
    let subStructures: [CodeStructure]
    
    convenience init(structure: [String: SourceKitRepresentable], contents: String) {
        self.init(structure: structure, contents: contents, indent: 0)
    }
    
    private init(structure: [String: SourceKitRepresentable], contents: String, indent: Int) {
        self.kind = structure[SwiftDocKey.kind.rawValue] as? String
        self.name = structure[SwiftDocKey.name.rawValue] as? String
        self.typeName = structure[SwiftDocKey.typeName.rawValue] as? String
        self.offset = structure[SwiftDocKey.offset.rawValue] as? Int64
        self.length = structure[SwiftDocKey.length.rawValue] as? Int64
        self.nameOffset = structure[SwiftDocKey.nameOffset.rawValue] as? Int64
        self.nameLength = structure[SwiftDocKey.nameLength.rawValue] as? Int64
        self.bodyOffset = structure[SwiftDocKey.bodyOffset.rawValue] as? Int64
        self.bodyLength = structure[SwiftDocKey.bodyLength.rawValue] as? Int64
        self.body = CodeStructure.content(contents: contents, offset: self.bodyOffset, length: self.bodyLength)
        self.content = CodeStructure.content(contents: contents, offset: self.offset, length: self.length)
        self.indent = indent
        
        let substructure = structure[SwiftDocKey.substructure.rawValue] as? Array<[String: SourceKitRepresentable]> ?? []
        
        var elements: [CodeStructure] = []
        for structure in substructure {
            elements.append(CodeStructure(structure: structure, contents: contents, indent: indent + 2))
        }
        self.subStructures = elements
    }
    
    static func content(contents: String, offset: Int64?, length: Int64?) -> String? {
        if let offset = offset, let length = length {
            let utf8contents = contents.utf8
            let startIndex = utf8contents.index(utf8contents.startIndex, offsetBy: Int(offset))
            let endIndex = utf8contents.index(startIndex, offsetBy: Int(length))
            return String(utf8contents[startIndex..<endIndex])
        }
        return nil
    }
}

extension CodeStructure: CustomDebugStringConvertible {
    var debugDescription: String {
        let indentText = String(repeating: " ", count: self.indent)
        
        var description = indentText + "{kind: '\(self.kind ?? "")', name: '\(self.name ?? "")'"
        
        if self.subStructures.count > 0 {
            var subElementDescriptions: [String] = []
            for element in self.subStructures {
                subElementDescriptions.append(element.debugDescription)
            }
            let subElementText = subElementDescriptions.joined(separator: "\n")
            
            description = description + "\n" + subElementText + "\n" + indentText + "}"
        } else {
            description = description + "}"
        }
        
        return description
    }
}
