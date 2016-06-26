#!/usr/bin/env xcrun swift

import Foundation

let args = Process.arguments

if args.count < 2 {
  print("[ERROR]: Missing path to .xcassets folder.")
  exit(1)
}

var path = args[1]
let fileManager = NSFileManager.defaultManager()

//MARK: - Helpers

func enumWithName(name: String, cases: [String], indents: Int = 0, shouldClose: Bool = true) -> String {
  var indentStr = ""
  for _ in 0...indents {
    indentStr.appendContentsOf("\t")
  }
  
  var result = indentStr + "enum \(name): String {\n"
  for image in cases {
    result.appendContentsOf(indentStr + "\t" + "case \(image)\n")
  }
  
  if (shouldClose) {
    result.appendContentsOf(indentStr + "}")
  }
  
  return result
}

func enumWithName(name: String, fromRoot root: String, indents: Int = 0, shouldClose: Bool = false) -> String {
  var enumString = String()
  
  let enumerator = fileManager.enumeratorAtURL(NSURL(fileURLWithPath: root),
                                               includingPropertiesForKeys: [NSURLIsDirectoryKey],
                                               options: [.SkipsHiddenFiles, .SkipsSubdirectoryDescendants],
                                               errorHandler: nil)
  
  let paths = (enumerator?.allObjects as! [NSURL]).flatMap() { return $0.lastPathComponent }
  
  let imageSets = paths.filter() { return $0.hasSuffix(".imageset") }
                          .map() { return ($0 as NSString).stringByDeletingPathExtension }
  
  let folders = paths.filter() { return !$0.hasSuffix(".imageset") && !$0.hasSuffix(".json") && !$0.hasSuffix(".appiconset") }
  
  enumString.appendContentsOf(enumWithName(name, cases: imageSets, indents: indents, shouldClose: shouldClose))
  
  for folder in folders {
    enumString.appendContentsOf("\n")
    let _enum = enumWithName(folder, fromRoot: (root as NSString).stringByAppendingPathComponent(folder), indents: indents + 1, shouldClose: true)
    enumString.appendContentsOf(_enum)
  }
  
  return enumString
}

//MARK: - Procedure

let assetsPathComponent = "Assets.xcassets"

if ((path as NSString).lastPathComponent != assetsPathComponent) {
  path = (path as NSString).stringByAppendingPathComponent(assetsPathComponent)
}

var fileString = "import UIKit\n\n"
fileString.appendContentsOf("extension UIImage {\n\n")

fileString.appendContentsOf(enumWithName("AppImage", fromRoot: path, indents: 0))

fileString.appendContentsOf("\n\t}")

let pathToWrite = (fileManager.currentDirectoryPath as NSString).stringByAppendingPathComponent("UIImage+AppImage.swift")

do {
  _ = try fileString.writeToFile(pathToWrite, atomically: true, encoding: NSUTF8StringEncoding)
  print("Created UIImage+AppImage.swift at \(pathToWrite)")
} catch {
  print("[ERROR]: Could not write to file.")
  exit(1)
}

