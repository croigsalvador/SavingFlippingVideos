//
//  URL+Files.swift
//  SavingFlippingVideos
//
//  Created by Carlos Roig on 03/07/2019.
//  Copyright © 2019 Vitcord. All rights reserved.
//

import Foundation

extension URL {
    
    static func createFileURL(at path: String = NSTemporaryDirectory(),
                              pathExtension: String = "mov") -> URL {
        
        let outputFilaName = ProcessInfo
            .processInfo
            .globallyUniqueString
        
        return URL(fileURLWithPath: path)
            .appendingPathComponent(outputFilaName,
                                    isDirectory: false)
            .appendingPathExtension(pathExtension)
    }
}
