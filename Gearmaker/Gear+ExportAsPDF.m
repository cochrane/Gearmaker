//
//  Gear+ExportAsPDF.m
//  Gearmaker
//
//  Created by Torsten Kammer on 17.04.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "Gear+ExportAsPDF.h"

@implementation Gear (ExportAsPDF)

- (BOOL)writePDFToURL:(NSURL *)url error:(NSError **)error;
{
	CGFloat diameter = self.kopfkreisdurchmesser * 1.05;
	
	CGRect rect = CGRectMake(0.0f, 0.0f, diameter, diameter);
	CGContextRef context = CGPDFContextCreateWithURL((__bridge CFURLRef) url, &rect, NULL);
    if (!context) {
        if (error)
            *error = [NSError errorWithDomain:@"Gearmaker" code:0 userInfo:@{       NSLocalizedDescriptionKey:@"The PDF file could not be created."
                                                                             }];
        return NO;
    }
	
	CGPDFContextBeginPage(context, NULL);
	[self drawInContext:context size:rect.size];
	CGPDFContextEndPage(context);
	
	CGPDFContextClose(context);
	
	CGContextRelease(context);
	
	return YES;
}

- (void)drawInContext:(CGContextRef)context size:(CGSize)size
{
	NSArray *outlinePoints = [self getOutlinePointsAtInveral:self.pointInterval];
	
	// Prepare translation
	CGContextTranslateCTM(context, size.width * 0.5, size.height * 0.5);
	
	// Scale
	CGFloat diameter = self.kopfkreisdurchmesser * 1.05;
	CGContextScaleCTM(context, size.width / diameter, size.height / diameter);
	
	// Draw gear
	CGContextBeginPath(context);
	NSPoint start = [outlinePoints[0] pointValue];
	CGContextMoveToPoint(context, start.x, start.y);
	for (NSValue *pointValue in outlinePoints)
	{
		NSPoint point = pointValue.pointValue;
		CGContextAddLineToPoint(context, point.x, point.y);
	}
	CGContextClosePath(context);
	
	CGContextSetFillColor(context, (CGFloat [4]) { 0.5, 0.5, 0.5, 1.0 });
	
	CGContextSetLineWidth(context, 1.0);
	
	CGContextDrawPath(context, kCGPathFillStroke);
}

@end
