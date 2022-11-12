//
//  Gear.m
//  Gearmaker
//
//  Created by Torsten Kammer on 28.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "Gear.h"

#import "Involute.h"
#import "NSArray+Map.h"

@interface Gear()

- (void)_generateData;

@end

@implementation Gear

- (CGFloat)kopfhoehe
{
	return self.module;
}
- (CGFloat)kopfspiel
{
	return self.module * self.kopfspielfaktor;
}
- (CGFloat)fusshoehe
{
	return self.module + self.kopfspiel;
}
- (CGFloat)teilkreisdurchmesser
{
	return ((CGFloat) self.teeth) * self.module;
}
- (CGFloat)fusskreisdurchmesser
{
	return self.teilkreisdurchmesser - 2.0 * self.fusshoehe;
}
- (CGFloat)kopfkreisdurchmesser
{
	return self.teilkreisdurchmesser + 2.0 * self.kopfhoehe;
}
- (CGFloat)grundkreisdurchmesser
{
	return self.teilkreisdurchmesser * cos(self.eingriffwinkel);
}

#pragma mark - Teeth

- (NSArray *)getToothFlankPointsAtIntervals:(CGFloat)interval;
{	
	CGFloat gebogeneHoehe = (self.kopfkreisdurchmesser - self.grundkreisdurchmesser) * 0.5;
	
	NSUInteger pointsInInterval = ceil(gebogeneHoehe / interval) + 1; // +1 to get everything in the interval
	CGFloat actualInterval = gebogeneHoehe / ceil(gebogeneHoehe / interval);
	
	NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:pointsInInterval + 1];
	
	// First point at fusskreis.
	[points addObject:[NSValue valueWithPoint:CGPointMake(self.fusskreisdurchmesser * 0.5, 0.0)]];
	
	Involute *curve = [[Involute alloc] init];
	curve.baseCircleRadius = self.grundkreisdurchmesser * 0.5;
	
	for (NSUInteger i = 0; i < pointsInInterval; i++)
	{
		CGFloat radius = self.grundkreisdurchmesser*0.5 + i*actualInterval;
		CGFloat angle = [curve angleForIntersectionWithCircleRadius:radius];
		[points addObject:[NSValue valueWithPoint:[curve pointAt:angle]]];
	}
	
	return [points copy];
}

- (NSArray *)getOutlinePointsAtInveral:(CGFloat)interval;
{
	NSArray *toothFlank = [self getToothFlankPointsAtIntervals:interval];
	NSMutableArray *reverseToothFlank = [NSMutableArray arrayWithCapacity:toothFlank.count];
	for (NSValue *point in toothFlank.reverseObjectEnumerator)
	{
		NSValue *value = [NSValue valueWithPoint:NSMakePoint(point.pointValue.x, -point.pointValue.y)];
		[reverseToothFlank addObject:value];
	}

	// Find out how much angle has to be added to the reverse side
	Involute *curve = [[Involute alloc] init];
	curve.baseCircleRadius = self.grundkreisdurchmesser * 0.5;
	CGFloat angleToTeilkreis = [curve angleForIntersectionWithCircleRadius:self.teilkreisdurchmesser * 0.5];
	CGPoint intersectionPoint = [curve pointAt:angleToTeilkreis];
	CGFloat additionalAngle = atan2(intersectionPoint.y, intersectionPoint.x);
	
	NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:toothFlank.count * 2 * self.teeth];
	
	for (NSUInteger i = 0; i < self.teeth; i++)
	{
		NSAffineTransform *rotate = [NSAffineTransform transform];
		[rotate rotateByRadians:M_PI * 2.0 * (CGFloat) i / (CGFloat) self.teeth];
		
		NSArray *rotatedToothFlank = [toothFlank map:^(NSValue *point){
			return [NSValue valueWithPoint:[rotate transformPoint:point.pointValue]];
		}];
		
		[points addObjectsFromArray:rotatedToothFlank];
		
		NSAffineTransform *reverseFlankRotate = [NSAffineTransform transform];
		[reverseFlankRotate rotateByRadians:2.0 * additionalAngle + M_PI * 2.0 * (0.5 + (CGFloat) i) / (CGFloat) self.teeth];
		
		NSArray *rotatedReverseToothFlank = [reverseToothFlank map:^(NSValue *point){
			return [NSValue valueWithPoint:[reverseFlankRotate transformPoint:point.pointValue]];
		}];
		
		[points addObjectsFromArray:rotatedReverseToothFlank];
	}
	
	return [points copy];
}

#pragma mark - 3D

@synthesize vertices=_vertices;
@synthesize polygons=_polygons;

- (NSArray *)vertices
{
    if (!_vertices)
        [self _generateData];
    return _vertices;
}

- (NSArray *)polygons
{
    if (!_polygons)
        [self _generateData];
    
    return _polygons;
}

- (NSArray *)triangulatedElements
{
    NSMutableArray *elements = [NSMutableArray array];
    
    for (NSArray *polygon in self.polygons)
    {
        for (NSUInteger i = 2; i < polygon.count; ++i)
        {
            [elements addObject:polygon[0]];
            [elements addObject:polygon[i-1]];
            [elements addObject:polygon[i]];
        }
    }
    
    return elements;
}

- (NSString *)objString
{
    NSMutableString *string = [NSMutableString stringWithString:@"# Created with Gearmaker\n"];
    
    for (NSValue *value in self.vertices)
    {
        float point[3];
        [value getValue:point];
        
        [string appendFormat:@"v %.6f %.6f %.6f\n", point[0], point[1], point[2]];
    }
    
    for (NSArray *polygon in self.polygons)
    {
        [string appendString:@"f"];
        for (NSNumber *number in polygon)
            [string appendFormat:@" %@", number];
        
        [string appendString:@"\n"];
    }
    
    return [string copy];
}

- (NSString *)triangulatedObjString
{
    NSMutableString *string = [NSMutableString stringWithString:@"# Created with Gearmaker\n"];
    
    for (NSValue *value in self.vertices)
    {
        float point[3];
        [value getValue:point];
        
        [string appendFormat:@"v %.6f %.6f %.6f\n", point[0], point[1], point[2]];
    }
    
    NSArray *triangulatedElements = self.triangulatedElements;
    
    for (NSUInteger i = 0; i < triangulatedElements.count; i += 3)
    {
        [string appendFormat:@"f %@ %@ %@\n",
         triangulatedElements[i+0],
         triangulatedElements[i+1],
         triangulatedElements[i+2]];
    }
    
    return [string copy];
}

- (void)_generateData
{
    NSArray *outline = [self getOutlinePointsAtInveral:self.pointInterval];
    
    NSMutableArray *mutableVertices = [NSMutableArray array];
    
    CGFloat halfWidth = self.thickness * 0.5;
    
    // Print vertices on top
    for (NSValue *value in outline.reverseObjectEnumerator)
    {
        NSPoint point = value.pointValue;
        [mutableVertices addObject:[NSValue valueWithBytes:(float [3]) { point.x, halfWidth, point.y } objCType:@encode(float [3])]];
    }
    

    
    // Print vertices below
    for (NSValue *value in outline.reverseObjectEnumerator)
    {
        NSPoint point = value.pointValue;
        [mutableVertices addObject:[NSValue valueWithBytes:(float [3]) { point.x, -halfWidth, point.y } objCType:@encode(float [3])]];
    }
    
    
    // Create center vertex on top
    [mutableVertices addObject:[NSValue valueWithBytes:(float [3]) { 0.0f, halfWidth, 0.0f } objCType:@encode(float [3])]];
    // and below
    [mutableVertices addObject:[NSValue valueWithBytes:(float [3]) { 0.0f, -halfWidth, 0.0f } objCType:@encode(float [3])]];
    
    _vertices = [mutableVertices copy];
    
    NSMutableArray *mutablePolygons = [NSMutableArray array];
    
    // Add wall faces
    for (NSUInteger i = 0; i < outline.count; i++)
        [mutablePolygons addObject:@[
         @( (i%outline.count)+1 ),
         @( ((i)%outline.count)+outline.count+1 ),
         @( ((i+1)%outline.count)+outline.count+1 ),
         @( ((i+1)%outline.count)+1 )
         ]];
    
    // Add tooth faces
    NSUInteger pointsPerTeeth = outline.count / self.teeth;
    for (NSUInteger i = 0; i < self.teeth; i++)
    {
        // Above
        NSMutableArray *above = [NSMutableArray array];
        for (NSUInteger j = 1; j <= pointsPerTeeth; j++)
            [above addObject:@( j + i*pointsPerTeeth )];
        [mutablePolygons addObject:above];
        
        // Below - reverse for correct face winding
        NSMutableArray *below = [NSMutableArray array];
        for (NSUInteger j = pointsPerTeeth; j > 0; j--)
            [below addObject:@( j + i*pointsPerTeeth + outline.count )];
        [mutablePolygons addObject:below];
    }
    
    // Add central faces - top
    for (NSUInteger i = 0; i < self.teeth; i++)
    {
        NSUInteger triangleStart = i*pointsPerTeeth+1;
        NSUInteger triangleEnd = (i+1) * pointsPerTeeth;
        NSUInteger nextStart = ((i+1)*pointsPerTeeth+1) % outline.count;
        
        [mutablePolygons addObject:@[
                                     @( triangleStart ),
                                     @( triangleEnd ),
                                     @( _vertices.count-1 )
                                     ]];
        [mutablePolygons addObject:@[
                                     @( triangleEnd ),
                                     @( nextStart ),
                                     @( _vertices.count-1 )
                                     ]];
    }
    
    // Central faces - bottom
    for (NSUInteger i = self.teeth; i > 0; i--)
    {
        NSUInteger triangleStart = i * pointsPerTeeth;
        NSUInteger triangleEnd = triangleStart - pointsPerTeeth + 1;
        NSUInteger nextStart = triangleEnd - 1;
        if (i == 1) {
            nextStart = outline.count;
        }
        
        [mutablePolygons addObject:@[
                                     @( triangleStart + outline.count ),
                                     @( triangleEnd + outline.count ),
                                     @( _vertices.count )
                                     ]];
        [mutablePolygons addObject:@[
                                     @( triangleEnd + outline.count ),
                                     @( nextStart + outline.count ),
                                     @( _vertices.count )
                                     ]];
    }
    
    _polygons = [mutablePolygons copy];
}

#pragma mark - Loading

- (BOOL)loadFrom:(NSData *)data error:(NSError *__autoreleasing*)outError; {
    NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:outError];
    if (!dict) return NO;
    
    if (!dict[@"zaehne"] || !dict[@"modul"] || !dict[@"kopfspielfaktor"] || !dict[@"eingriffwinkel"] || !dict[@"dicke"] || !dict[@"pointInterval"])
    {
        if (outError)
            *outError = [NSError errorWithDomain:@"GearDocument" code:1 userInfo:@{
                      NSLocalizedDescriptionKey : NSLocalizedString(@"Dem Dokument fehlen wichtige Daten.", @"not all keys present in file - description"),
                      NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Das Dokument ist beschädigt oder in einem Format, dass Gearmaker nicht erkennt.", @"not all keys present in file - recovery suggestion"),
                         }];
        return NO;
    }
    
    self.module = [dict[@"modul"] doubleValue];
    self.teeth = [dict[@"zaehne"] unsignedIntegerValue];
    self.eingriffwinkel = [dict[@"eingriffwinkel"] doubleValue];
    self.kopfspielfaktor = [dict[@"kopfspielfaktor"] doubleValue];
    self.pointInterval = [dict[@"pointInterval"] doubleValue];
    
    self.thickness = [dict[@"dicke"] doubleValue];
    return YES;
}

@end
