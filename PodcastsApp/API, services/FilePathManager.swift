//
//  FileService.swift
//  PodcastsApp
//
//  Created by Zinko Viacheslav on 14.09.2019.
//  Copyright © 2019 Zinko Viacheslav. All rights reserved.
//

import UIKit


class FilePathManager {
	
	private let ioQueue: DispatchQueue
	private let fileManager: FileManager
	public static let shared = FilePathManager()
	private var documentsDirPath: URL {
		return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
	}
	
	
	private init() {
		let ioQueueName = "com.zslavman.\(type(of: self)).FilePathManagerQueue"
		ioQueue = DispatchQueue(label: ioQueueName)
		fileManager = FileManager.default
	}
	
	
	public func moveFileToDocumentsDir(tempURL: URL) {
		var destPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
		let fileName = tempURL.lastPathComponent
		destPaths.appendPathComponent(fileName)
		if !fileManager.fileExists(atPath: destPaths.absoluteString) {
			do {
				try fileManager.moveItem(at: tempURL, to: destPaths)
				print("Successfully moved file to documentDirectory!")
			}
			catch let err {
				print("Failed to move file:", err.localizedDescription)
			}
		}
	}
	
	
	public func isFileExists(pathString: String) -> Bool {
		return fileManager.fileExists(atPath: pathString)
	}
	
	
	public func exploreDir(dir: URL) -> [URL] {
		var existsFilePaths = [URL]()
		do {
			let fileNames = try fileManager.contentsOfDirectory(atPath: dir.path)
			for item in fileNames {
				let fileURL = dir.appendingPathComponent(item)
				existsFilePaths.append(fileURL)
			}
		}
		catch {
			print("Failed to read directory – bad permissions, perhaps?")
		}
		return existsFilePaths // ["ContentInfo.plist", "Contents", "META-INF"]
	}
	
	
	public func exploreDocumentsDir() -> [URL] {
		return exploreDir(dir: documentsDirPath)
	}
	
	
	public func createImageFromURL(pathString: String) -> UIImage? {
		if isFileExists(pathString: pathString) {
			let img = UIImage(contentsOfFile: pathString)
			return img
		}
		return nil
	}

	
}
