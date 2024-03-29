//
//  ThumbnailProvider.swift
//  ThumbnailExtension
//
//  Created by Torsten Kammer on 12.11.22.
//  Copyright © 2022 Torsten Kammer. All rights reserved.
//

import Cocoa
import QuickLookThumbnailing

@objc class ThumbnailProvider: QLThumbnailProvider {
    
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        do {
            let gear = try Gear.load(fromUrl: request.fileURL)
            
            let reply = QLThumbnailReply(contextSize: request.maximumSize) { context in
                gear.draw(in: context, size: request.maximumSize)
                return true
            }
            handler(reply, nil)
        } catch {
            handler(nil, error)
        }
    }
    
}
