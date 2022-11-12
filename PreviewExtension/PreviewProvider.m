//
//  PreviewProvider.m
//  PreviewExtension
//
//  Created by Torsten Kammer on 12.11.22.
//  Copyright © 2022 Torsten Kammer. All rights reserved.
//

#import "PreviewProvider.h"

#import "GenerateGearImage.h"

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
    CGSize size = CGSizeMake(800, 800);
    QLPreviewReply* reply = [[QLPreviewReply alloc] initWithContextSize:CGSizeMake(800, 800) isBitmap:NO drawingBlock:^BOOL(CGContextRef  _Nonnull context, QLPreviewReply * _Nonnull reply, NSError *__autoreleasing  _Nullable * _Nullable error) {
        return GenerateGearImage(context, size, (__bridge CFURLRef)(request.fileURL));
    }];
    
    //You can also create a QLPreviewReply with a fileURL of a supported file type, by drawing directly into a bitmap context, or by providing a PDFDocument.
    
    handler(reply, nil);
}

@end

