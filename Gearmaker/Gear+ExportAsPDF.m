//
//  Gear+ExportAsPDF.m
//  Gearmaker
//
//  Created by Torsten Kammer on 17.04.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "Gear+ExportAsPDF.h"

@implementation Gear (ExportAsPDF)

- (void)writePDFToURL:(NSURL *)url;
{
	CGContextRef context = CGPDFContextCreateWithURL((__bridge CFURLRef) url, NULL, NULL);
	CGPDFContextBeginPage(context, <#CFDictionaryRef pageInfo#>);
	CGPDFContextEndPage(context);
}

@end
