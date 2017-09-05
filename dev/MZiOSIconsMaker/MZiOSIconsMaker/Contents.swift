//
//  Contents.swift
//  iOSIconsMaker
//
//  Created by lolimizuki on 2016/4/13.
//  Copyright © 2016年 Inaba Mizuki. All rights reserved.
//

import Foundation


// MARK: ContentImage
class ContentImage {

    var filename: String = ""

    var idiom: String

    var scale: String

    var size: String

    lazy var sizeNumber: Double = {
        let compoenets = self.size.components(separatedBy: "x")
        return Double(compoenets[0])!
    }()

    lazy var scaleNumber: Int = {
        let str = self.scale.replacingOccurrences(of: "x", with: "")
        return Int(str)!
    }()

    init?(data: [String: AnyObject]) {
        guard
            let size = data["size"] as? String,
            let idiom = data["idiom"] as? String,
            let scale = data["scale"] as? String
            else { return nil }

        self.idiom = idiom
        self.scale = scale
        self.size = size
    }

    func dataValue() -> [String: AnyObject] {
        return [
            "size": size as AnyObject,
            "idiom": idiom as AnyObject,
            "filename": filename as AnyObject,
            "scale": scale as AnyObject
        ]
    }

    func genFileName(autoFill: Bool = false) -> String {
        let sizeString = sizeNumber - Double(Int(sizeNumber)) > 0 ?
            String(format: "%0.1f", sizeNumber) : String(format: "%d", Int(sizeNumber))

        let newFileName = "Icon\(sizeString)@\(scaleNumber)x.png"

        if autoFill { filename = newFileName }

        return newFileName
    }
}


// MARK: ContentInfo
class ContentInfo {

    var version: Int

    var author: String

    init?(data: [String: AnyObject]) {
        guard
            let version = data["version"] as? Int,
            let author = data["author"] as? String
            else { return nil }

        self.version = version
        self.author = author
    }

    func dataValue() -> [String: AnyObject] {
        return [
            "version": version as AnyObject,
            "author": author as AnyObject
        ]
    }
}


// MARK: Contents
class Contents {

    var images: [ContentImage]

    var info: ContentInfo

    init?(contentsData: [String: AnyObject]) {
        guard
            let imageDatas = contentsData["images"] as? [[String: AnyObject]],
            let infoData = contentsData["info"] as? [String: AnyObject]
            else { return nil }

        self.images = imageDatas.map { data in return ContentImage(data: data)! }
        self.info = ContentInfo(data: infoData)!
    }

    func dataValue() -> [String: AnyObject] {
        let imageDatas = images.map { image in return image.dataValue() }

        return [
            "images": imageDatas as AnyObject,
            "info": info.dataValue() as AnyObject
        ]
    }
}
