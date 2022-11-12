//
//  PreviewProvider.swift
//  PreviewExtension
//
//  Created by Torsten Kammer on 12.11.22.
//  Copyright © 2022 Torsten Kammer. All rights reserved.
//

import Cocoa
import QuickLookUI

@objc class PreviewProvider: QLPreviewProvider  {
    
    func providePreview(
        for request: QLFilePreviewRequest,
        completionHandler handler: @escaping (QLPreviewReply?, Error?) -> Void
    ) {
        do {
            let data = try Data(contentsOf: request.fileURL)
            let gear = Gear()
            try gear.load(from: data)
            
            let size = CGSize(width: 800, height: 800)
            let reply = QLPreviewReply(contextSize: size, isBitmap: false) { context, reply in
                gear.draw(in: context, size: size)
            }
            handler(reply, nil)
        } catch {
            handler(nil, error)
        }
    }

}
