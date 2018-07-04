//
// main.swift
//

import Foundation
import Commander
import FlowGraphDotConverterCore

let main = command (Option("output", default: "", description: "Output Directory Path"), Flag("hide-enter", description: "Hide Enter States"), VariadicArgument<String>("inFilePaths", description: "Input File Paths")) { (outDirPath, enter, inFilePaths) in
    for inFilePath in inFilePaths {
        FlowGraphDotConverter.convert(inFilePath: inFilePath, outDirPath: outDirPath, isRemoveEnter: enter)
    }
}

main.run()
