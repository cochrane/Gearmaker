//
//  PreviewProvider.m
//  PreviewExtension
//
//  Created by Torsten Kammer on 12.11.22.
//  Copyright © 2022 Torsten Kammer. All rights reserved.
//

#import "PreviewProvider.h"

#import "Gear.h"
#import "Gear+ExportAsPDF.h"

@implementation PreviewProvider

/*

 Use a QLPreviewProvider to provide data-based previews.
 
 To set up your extension as a data-based preview extension:

 - Modify the extension's Info.plist by setting
   <key>QLIsDataBasedPreview</key>
   <true/>
 
 - Add the supported content types to QLSupportedContentTypes array in the extension's Info.plist.

 - Change the NSExtensionPrincipalClass to this class.
   e.g.
   <key>NSExtensionPrincipalClass</key>
   <string>PreviewProvider</string>
 
 - Implement providePreviewForFileRequest:completionHandler:
 
 */

- (void)providePreviewForFileRequest:(QLFilePreviewRequest *)request completionHandler:(void (^)(QLPreviewReply * _Nullable reply, NSError * _Nullable error))handler
{
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
    
    CGSize size = CGSizeMake(800, 800);
    QLPreviewReply* reply = [[QLPreviewReply alloc] initWithContextSize:CGSizeMake(800, 800) isBitmap:NO drawingBlock:^BOOL(CGContextRef  _Nonnull context, QLPreviewReply * _Nonnull reply, NSError *__autoreleasing  _Nullable * _Nullable error) {
        [gear drawInContext:context size:size];
        return YES;
    }];
    handler(reply, nil);
}

@end

