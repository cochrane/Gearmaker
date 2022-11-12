//
//  ThumbnailProvider.m
//  ThumbnailExtension
//
//  Created by Torsten Kammer on 12.11.22.
//  Copyright © 2022 Torsten Kammer. All rights reserved.
//

#import "ThumbnailProvider.h"

#import "Gear.h"
#import "Gear+ExportAsPDF.h"

@implementation ThumbnailProvider

- (void)provideThumbnailForFileRequest:(QLFileThumbnailRequest *)request completionHandler:(void (^)(QLThumbnailReply * _Nullable, NSError * _Nullable))handler {

    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:request.fileURL options:0 error:&error];
    if (!data) {
        handler(nil, error);
        return;
    }
    Gear *gear = [[Gear alloc] init];
    if (![gear loadFrom:data error:&error]) {
        handler(nil, error);
        return;
    }
    
     handler([QLThumbnailReply replyWithContextSize:request.maximumSize drawingBlock:^BOOL(CGContextRef  _Nonnull context) {
         [gear drawInContext:context size:request.maximumSize];
         return YES;
     }], nil);
}

@end
