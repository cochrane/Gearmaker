//
//  ThumbnailProvider.m
//  ThumbnailExtension
//
//  Created by Torsten Kammer on 12.11.22.
//  Copyright © 2022 Torsten Kammer. All rights reserved.
//

#import "ThumbnailProvider.h"

#import "GenerateGearImage.h"

@implementation ThumbnailProvider

- (void)provideThumbnailForFileRequest:(QLFileThumbnailRequest *)request completionHandler:(void (^)(QLThumbnailReply * _Nullable, NSError * _Nullable))handler {
    
   // Second way: Draw the thumbnail into a context passed to your block, set up with Core Graphics's coordinate system.
   // Second way: Draw the thumbnail into a context passed to your block, set up with Core Graphics's coordinate system.
     handler([QLThumbnailReply replyWithContextSize:request.maximumSize drawingBlock:^BOOL(CGContextRef  _Nonnull context) {
         // Draw the thumbnail here.
         return GenerateGearImage(context, request.maximumSize, (__bridge CFURLRef)(request.fileURL));
     }], nil);
}

@end
