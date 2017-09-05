//
//  main.swift
//  iOSIconsMaker
//
//  Created by lolimizuki on 2016/4/13.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

import Foundation
import Cocoa


// MARK: ETC

func anyKeyToEnd() {
    print(" ... 隨意結束👒")

    let fh = FileHandle.standardInput
    let data = fh.availableData
    _ = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
}


func anyKeyToEnd(errorMessage message: String) -> Never {
    print(message)
    anyKeyToEnd()

    abort()
}


// MARK: File

func getCurrentDirectoryPath() -> String {
    return FileManager.default.currentDirectoryPath
}

func createAndGetAppIconAssets() -> String {
    let assetsPath = getCurrentDirectoryPath() + "/" + "AppIcon.appiconset"
    let url = URL(fileURLWithPath: assetsPath, isDirectory: true)

    do {
        try FileManager.default.createDirectory(at: url,
                                                withIntermediateDirectories: false,
                                                attributes: nil)
    } catch let error {
        anyKeyToEnd(errorMessage: "Fail to create AppIcon.appiconset, error: \(error.localizedDescription)")
    }

    return assetsPath
}


// MARK: Image

func getOriginalImage() -> NSImage? {
    let currentDirectoryPath = getCurrentDirectoryPath()
    let path = currentDirectoryPath + "/" + "Icon.png"

    guard FileManager.default.fileExists(atPath: path) else {
        anyKeyToEnd(errorMessage: "\(path) is not found")
    }
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
        anyKeyToEnd(errorMessage: "Fail to convert to data from path (\(path))")
    }
    guard let image = NSImage(data: data) else {
        anyKeyToEnd(errorMessage: "Can not make image from data")
    }

    return image
}

func resizeImage(_ originalImage: NSImage, size: NSSize) -> NSImage? {
    let resizedImage = NSImage(size: size)

    resizedImage.lockFocus()

    let context = NSGraphicsContext.current!
    context.imageInterpolation = .high
    originalImage.draw(in: NSRect(origin: NSPoint.zero, size: size),
                       from: NSRect(origin: NSPoint.zero, size: originalImage.size),
                       operation: .copy,
                       fraction: 1)

    resizedImage.unlockFocus()

    return resizedImage
}

func saveImage(_ image: NSImage, toPath path: String, withName name: String) {
    let imageData = image.tiffRepresentation!
    let bitmapImageRep = NSBitmapImageRep(data: imageData)!

    let pngData = bitmapImageRep.representation(using: .png, properties: [NSBitmapImageRep.PropertyKey.interlaced: true])
    let pathWIthName = path + "/" + name

    do {
        try pngData?.write(to: URL(fileURLWithPath: pathWIthName), options: .atomicWrite)
    } catch let error {
        print("Fail to write png data to path: \(pathWIthName), error: \(error.localizedDescription)")
    }
}


// MARK: Json

func dictionaryData(withJsonFileName name: String = "Contents.json") -> [String: AnyObject]? {
    let currentDirectoryPath = getCurrentDirectoryPath()
    let path = currentDirectoryPath + "/" + name

    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
        fatalError("Fail to get data from: \(path)")
    }

    guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject] else {
        return nil
    }

    return json
}

func getContents() -> Contents {
    let data = dictionaryData()!
    return Contents(contentsData: data)!
}

func saveContents(_ contents: Contents, toPath path: String, withName name: String) {
    let contentsData = try! JSONSerialization.data(withJSONObject: contents.dataValue(), options: [.prettyPrinted])

    do {
        try contentsData.write(to: URL(fileURLWithPath: path + "/" + name), options: [.atomicWrite])
    } catch let error {
        anyKeyToEnd(errorMessage: "Fail to save contect, error: \(error.localizedDescription)")
    }
}


// MARK: Main

let originalIconImage = getOriginalImage()!
let contents = getContents()
let assetsPath = createAndGetAppIconAssets()

contents.images.forEach { contentImage in
    let fileName = contentImage.genFileName(autoFill: true)
    let iconSize = contentImage.sizeNumber
    let iconScale = contentImage.scaleNumber

    let iconRealSize = NSSize(width: CGFloat(iconSize*Double(iconScale)),
                              height: CGFloat(iconSize*Double(iconScale)))
    let resizedIconImage = resizeImage(originalIconImage, size: iconRealSize)!

    saveImage(resizedIconImage, toPath: assetsPath, withName: fileName)
}

saveContents(contents, toPath: assetsPath, withName: "Contents.json")

anyKeyToEnd()
