//
//  Gear3D.m
//  Gearmaker
//
//  Created by Torsten Kammer on 28.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "Gear3D.h"

#import "Gear.h"

@interface Gear3D ()

- (void)_generateData;

@end

@implementation Gear3D

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
	NSArray *outline = [self.gear getOutlinePointsAtInveral:self.pointInterval];
	
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
	NSUInteger pointsPerTeeth = outline.count / self.gear.teeth;
	for (NSUInteger i = 0; i < self.gear.teeth; i++)
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
	
	// Add central face - top
	NSMutableArray *centralTop = [NSMutableArray array];
	for (NSUInteger i = 0; i < self.gear.teeth; i++)
	{
		[centralTop addObject:@( i*pointsPerTeeth+1 )];
		[centralTop addObject:@( (i+1)*pointsPerTeeth )];
	}
	[mutablePolygons addObject:centralTop];
	
	// Central face - bottom
	NSMutableArray *centralBottom = [NSMutableArray array];
	for (NSUInteger i = self.gear.teeth; i > 0; i--)
	{
		[centralBottom addObject:@( i*pointsPerTeeth + outline.count )];
		[centralBottom addObject:@( (i-1)*pointsPerTeeth+1 + outline.count )];
	}
	[mutablePolygons addObject:centralBottom];
	
	_polygons = [mutablePolygons copy];
}

@end
