#!/usr/bin/swift

//
//  main.swift
//  MZFattyMaker
//
//  Created by lolimizuki on 2017/9/1.
//  Copyright © 2017年 lolimizuki. All rights reserved.
//

import Foundation

let fileManager = FileManager.default
let currentDirectoryPath = FileManager.default.currentDirectoryPath
let debugiPhonePath = currentDirectoryPath + "/" + "Debug-iphoneos"
let debugiPhoneSimulatorPath = currentDirectoryPath + "/" + "Debug-iphonesimulator"

@discardableResult
private func _shell(_ args: String) -> String {
    var outstr = ""
    let task = Process()
    task.launchPath = "/bin/sh"
    task.arguments = ["-c", args]
    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
        outstr = output as String
    }
    task.waitUntilExit()
    return outstr
}

private func _checkExist() {
    guard fileManager.fileExists(atPath: debugiPhonePath) &&
        fileManager.fileExists(atPath: debugiPhoneSimulatorPath) else {
            print("'Debug-iphoneos or Debug-iphonesimulator' is not found")
            exit(0)
    }
}

private func _frameworkName() -> String {
    let fileNames = try? FileManager.default.contentsOfDirectory(atPath: debugiPhonePath).filter {
        return $0.components(separatedBy: ".").last == "framework"
    }

    guard let frameworkFullName = fileNames?.first else {
        print("Framework file not found")
        exit(0)
    }

    guard let frameworkName = frameworkFullName.components(separatedBy: ".").first else {
        print("No framework")
        exit(0)
    }

    return frameworkName
}

private func _cloneFramework(withName frameworkName: String) -> String {
    let fullName = frameworkName + ".framework"
    let source = debugiPhonePath + "/" + fullName
    let target = currentDirectoryPath

    var isDirectory = ObjCBool(true)
    let fullClonePath = target + "/" + fullName
    if fileManager.fileExists(atPath: fullClonePath, isDirectory: &isDirectory) {
        _shell("rm -r \(fullClonePath)")
    }

    _shell("cp -R \(source) \(target)")
    try! fileManager.removeItem(atPath: target + "/" + fullName + "/" + frameworkName)

    return target + "/" + fullName
}

private func _makeFatty(withName frameworkName: String) -> String {
    let fullName = frameworkName + ".framework"

    let command: String = {
        let lipo = "lipo -create -output \"\(frameworkName)\""
        let device = "Debug-iphoneos/\(fullName)/\(frameworkName)"
        let simulator = "Debug-iphonesimulator/\(fullName)/\(frameworkName)"

        return "\(lipo) \(device) \(simulator)"
    }()

    _shell(command)

    return currentDirectoryPath + "/" + frameworkName
}

private func _moveFatty(at fattyPath: String, into frameworkPath: String) {
    let fattyName = fattyPath.components(separatedBy: "/").last!
    try! fileManager.moveItem(atPath: fattyPath,
                              toPath: frameworkPath + "/" + fattyName)
}

private func _copySimulatorModules(with frameworkName: String,
                                   to newFrameworkPath: String) {
    let modulesSubPath = frameworkName + ".framework" +
        "/" + "Modules" +
        "/" + frameworkName + ".swiftmodule"
    
    let fromModulesPath = debugiPhoneSimulatorPath + "/" + modulesSubPath
    let contents = try! fileManager.contentsOfDirectory(atPath: fromModulesPath)
    
    let toModulesPath = newFrameworkPath + "/" +
        "Modules" +
        "/" + frameworkName + ".swiftmodule"
    
    contents.forEach {
        let from = fromModulesPath + "/" + $0
        let to = toModulesPath  + "/" + $0
        
        try! fileManager.moveItem(atPath: from, toPath: to)
    }
}


// MARK: Main

_checkExist()
let frameworkName = _frameworkName()
let fattyFrameworkPath = _cloneFramework(withName: frameworkName)
let fattyPath = _makeFatty(withName: frameworkName)
_moveFatty(at: fattyPath, into: fattyFrameworkPath)
_copySimulatorModules(with: frameworkName, to: fattyFrameworkPath)

print("你是一個成功的胖子 🎅")
