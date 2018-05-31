//
//  FlowGraphDotConverter.swift
//

import Foundation

public struct FlowGraphDotConverter {
    public static func convert(inFilePath: String, outDirPath: String, isRemoveEnter: Bool) {
        let inFileUrl = URL(fileURLWithPath: inFilePath)
        let outDirURL = self.outUrl(inFileURL: inFileUrl, outDirPath: outDirPath)
        self.convert(inFileUrl: inFileUrl, outDirUrl: outDirURL, isRemoveEnter: isRemoveEnter)
    }
    
    public static func convert(inFileUrl: URL, outDirUrl: URL, isRemoveEnter: Bool) {
        let graphInstances = FlowGraphDotConverter.loadGraphInstances(url: inFileUrl, isRemoveEnter: isRemoveEnter)
        
        let fileManager = FileManager.default
        var isDirectory = ObjCBool(false)
        
        if fileManager.fileExists(atPath: outDirUrl.path, isDirectory: &isDirectory) {
            if !isDirectory.boolValue {
                print("output path is not directory. \(outDirUrl)")
                return
            }
        } else {
            do {
                try fileManager.createDirectory(at: outDirUrl, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("create directory failed. \(outDirUrl)")
            }
        }
        
        guard !graphInstances.isEmpty else {
            print("graph not found.")
            return
        }
        
        for (address, instance) in graphInstances {
            guard let className = address.className() else {
                print("class name not found.")
                continue
            }
            
            let outFileUrl = outDirUrl.appendingPathComponent("\(className).dot")
            
            let dotText = instance.dotText()
            
            do {
                try dotText.write(to: outFileUrl, atomically: true, encoding: .utf8)
            } catch {
                print("write file failed. \(outFileUrl)")
                continue
            }
            
            print("write dot file: \(outFileUrl.path)")
        }
    }
    
    private static func outUrl(inFileURL: URL, outDirPath: String) -> URL {
        if outDirPath.isEmpty {
            return inFileURL.deletingLastPathComponent()
        } else {
            return URL(fileURLWithPath: outDirPath)
        }
    }
    
    static func loadGraphInstances(url: URL, isRemoveEnter: Bool) -> [CodeAddress: FlowGraphInstance] {
        let fileManager = FileManager.default
        var isDirectory = ObjCBool(false)
        
        if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                print("input path is not file.")
                return [:]
            }
        } else {
            print("input file not found. \(url.path)")
            return [:]
        }
        
        guard let scanner = FlowGraphScanner(url: url) else {
            print("scan failed.")
            return [:]
        }
        
        if isRemoveEnter {
            return scanner.enterRemovedInstances()
        } else {
            return scanner.flowGraphInstances
        }
    }
}
