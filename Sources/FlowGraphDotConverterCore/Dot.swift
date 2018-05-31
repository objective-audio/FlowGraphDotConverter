//
//  Dot.swift
//

import Foundation

struct Dot {
    static func digraphText(_ array: [String]) -> String {
        let joined = array.map { "    " + $0 }.joined(separator: "\n")
        return "digraph {\n" + joined + "\n}"
    }
    static func elementText(name: String, dictionary: [String: String]) -> String {
        return "\(name) [" + dictionary.map { (key, value) in "\(key) = \"\(value)\"" }.joined(separator: ", ") + "]"
    }
}
