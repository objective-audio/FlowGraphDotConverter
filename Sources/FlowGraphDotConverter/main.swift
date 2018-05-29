import Foundation
import Commander
import FlowGraphDotConverterCore

let main = command (Option("output", default: "", description: "Output Directory Path"), VariadicArgument<String>("inFilePaths", description: "Input File Paths")) { (outDirPath, inFilePaths) in
    for inFilePath in inFilePaths {
        FlowGraphDotConverter.convert(inFilePath: inFilePath, outDirPath: outDirPath)
    }
}

main.run()
