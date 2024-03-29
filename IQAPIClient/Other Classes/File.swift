//
//  File.swift
//  IQAPIClient
//
//  Created by Iftekhar on 05/02/21.
//

import Foundation

public struct File: Hashable, Codable {
    public let data: Data?
    public let mimeType: String
    public let fileName: String
    public let fileURL: URL?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(data)
        hasher.combine(mimeType)
        hasher.combine(fileName)
    }

    public static func == (lhs: File, rhs: File) -> Bool {
        return lhs.data == rhs.data
    }

    public init(data: Data?, mimeType: String, fileName: String, fileURL: URL? = nil) {
        self.data = data
        self.mimeType = mimeType
        self.fileName = fileName
        self.fileURL = fileURL
    }

    var description: String {

        var fileAttributes: [String: Any] = ["name": fileName,
                                             "type": mimeType]
        fileAttributes["url"] = fileURL?.absoluteString
        fileAttributes["size"] = data?.count

        var fileDescriptions: [String] = []

        if let data = data {
            fileDescriptions.append("data: \(data.count) byte")
        }

        fileDescriptions.append("mimeType: \(mimeType)")
        fileDescriptions.append("fileName: \(fileName)")

        if let fileURL = fileURL {
            fileDescriptions.append("fileURL: \"\(fileURL)\"")
        }

        return "File(\(fileDescriptions.joined(separator: ", ")))"
    }
}
