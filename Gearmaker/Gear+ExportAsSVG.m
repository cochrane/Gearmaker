//
//  Gear+ExportAsSVG.h
//  Gearmaker
//
//  Created by Torsten Kammer on 08.07.20.
//  Copyright © 2020 Torsten Kammer. All rights reserved.
//

#import "Gear+ExportAsSVG.h"

@implementation Gear (ExportAsSVG)

- (BOOL)writeSVGToURL:(NSURL *)url error:(NSError **)error;
{
    CGFloat diameter = self.kopfkreisdurchmesser;
    CGFloat offset = diameter*0.5;
        
    NSXMLElement *svg = [[NSXMLElement alloc] initWithName:@"svg" URI:@"http://www.w3.org/2000/svg"];
    [svg setAttributesWithDictionary:@{ @"version": @"1.1", @"width": [NSString stringWithFormat:@"%fmm", diameter], @"height": [NSString stringWithFormat:@"%fmm", diameter] }];
    
    NSMutableString *pathText = [[NSMutableString alloc] init];
    NSArray *outlinePoints = [self getOutlinePointsAtInveral:self.pointInterval];
    
    NSPoint start = [outlinePoints[0] pointValue];
    [pathText appendString:[NSString stringWithFormat:@"M %f,%f L", (start.x + offset), (start.y + offset)]];
    for (NSValue *pointValue in outlinePoints)
    {
        NSPoint point = pointValue.pointValue;
        [pathText appendString:[NSString stringWithFormat:@" %f,%f", (point.x + offset), (point.y + offset)]];
    }
    [pathText appendString:@" Z"];
    
    NSXMLElement *pathElement = [[NSXMLElement alloc] initWithName:@"path" URI:@"http://www.w3.org/2000/svg"];
    [pathElement setAttributesWithDictionary: @{ @"d": pathText, @"fill": @"#000000" }];
    
    CGFloat mmPerInch = 25.4;
    CGFloat dotsPerInch = 96.0;
    CGFloat dotsPerMm = dotsPerInch / mmPerInch;
    
    NSXMLElement *gElement = [[NSXMLElement alloc] initWithName:@"g" URI:@"http://www.w3.org/2000/svg"];
    [gElement setAttributesWithDictionary: @{ @"transform": [NSString stringWithFormat:@"scale(%f)", dotsPerMm] }];
    [gElement addChild:pathElement];
    
    [svg addNamespace:[NSXMLNode namespaceWithName:@"" stringValue:@"http://www.w3.org/2000/svg"]];
    [svg addChild:gElement];
    
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithRootElement:svg];
    document.characterEncoding = @"utf-8";
    NSData *documentData = [document XMLData];
    
    return [documentData writeToURL:url options:NSDataWritingAtomic
                              error:error];
}

@end
