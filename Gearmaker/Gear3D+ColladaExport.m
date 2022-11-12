//
//  Gear3D+ColladaExport.m
//  Gearmaker
//
//  Created by Torsten Kammer on 16.04.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "Gear3D+ColladaExport.h"

#import "NSXMLElement+SimplifiedCreation.h"

@implementation Gear (ColladaExport)

- (NSXMLDocument *)colladaDocumentUsingTriangulation:(BOOL)triangulate;
{
	// Header
	NSXMLElement *root = [NSXMLElement elementWithName:@"COLLADA"];
	[root addNamespace:[NSXMLNode namespaceWithName:@"" stringValue:@"http://www.collada.org/2005/11/COLLADASchema"]];
	[root addAttributeWithName:@"version" stringValue:@"1.4.1"];
	
	NSXMLElement *asset = [root addChildElementWithName:@"asset"];

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	formatter.dateFormat = @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
	formatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
	NSString *timeString = [formatter stringFromDate:[NSDate date]];
	
	[asset addChildElementWithName:@"created" stringValue:timeString];
	[asset addChildElementWithName:@"modified" stringValue:timeString];
	
	NSXMLElement *library_geometries = [root addChildElementWithName:@"library_geometries"];
	
	NSXMLElement *geometry = [library_geometries addChildElementWithName:@"geometry" attributes:@{ @"id" : @"gear" }];
	
	NSXMLElement *mesh = [geometry addChildElementWithName:@"mesh"];
	NSXMLElement *source = [mesh addChildElementWithName:@"source" attributes:@{ @"id" : @"s1" }];
	
	// Vertices
	NSArray *vertices = self.vertices;
	
	NSMutableString *values = [[NSMutableString alloc] init];
	for (NSValue *value in self.vertices)
	{
		float point[3];
		[value getValue:point];
		
		[values appendFormat:@"%.6f %.6f %.6f ", point[0], point[1], point[2]];
	}
	NSXMLElement *float_array = [source addChildElementWithName:@"float_array" stringValue:values];
	[float_array addAttributeWithName:@"id" stringValue:@"f1"];
	[float_array addAttribute:[NSXMLNode attributeWithName:@"count" stringValue:[NSString stringWithFormat:@"%lu", vertices.count * 3]]];
	
	NSXMLElement *techniqueCommon = [source addChildElementWithName:@"technique_common"];
	NSXMLElement *accessor = [techniqueCommon addChildElementWithName:@"accessor" attributes:@{
							  @"count" : @(vertices.count),
							  @"stride" : @(3),
							  @"source" : @"#f1"
							  }];
	[accessor addChildElementWithName:@"param" attributes:@{ @"name" : @"X", @"type" : @"float" }];
	[accessor addChildElementWithName:@"param" attributes:@{ @"name" : @"Y", @"type" : @"float" }];
	[accessor addChildElementWithName:@"param" attributes:@{ @"name" : @"Z", @"type" : @"float" }];


	NSXMLElement *verticesElement = [mesh addChildElementWithName:@"vertices" attributes:@{ @"id" : @"v1" }];
	[verticesElement addChildElementWithName:@"input" attributes:@{ @"semantic" : @"POSITION", @"source" : @"#s1" }];
	
	// Elements
	if (triangulate)
	{
		NSArray *triangleIndices = self.triangulatedElements;
		
		NSXMLElement *triangles = [mesh addChildElementWithName:@"triangles" attributes:@{ @"count" : @(triangleIndices.count / 3) }];
		
		[triangles addChildElementWithName:@"input" attributes:@{
		 @"offset" : @(0),
		 @"semantic" : @"VERTEX",
		 @"source" : @"#v1"
		 }];
		
		NSMutableString *indices = [NSMutableString string];
		for (NSNumber *num in triangleIndices)
			[indices appendFormat:@"%lu ", num.unsignedIntegerValue - 1];
		
		[triangles addChildElementWithName:@"p" stringValue:indices];
	}
	else
	{
		NSArray *polygons = self.polygons;
		
		NSXMLElement *polylist = [mesh addChildElementWithName:@"polylist"];
		[polylist addAttributeWithName:@"count" stringValue:[@(polygons.count) stringValue]];
		
		[polylist addChildElementWithName:@"input" attributes:@{
		 @"offset" : @(0),
		 @"semantic" : @"VERTEX",
		 @"source" : @"#v1"
		 }];
		
		NSMutableString *counts = [NSMutableString string];
		for (NSArray *polygon in polygons)
			[counts appendFormat:@"%lu ", polygon.count];
		[polylist addChildElementWithName:@"vcount" stringValue:counts];
		
		NSMutableString *indices = [NSMutableString string];
		for (NSArray *polygon in polygons)
			for (NSNumber *num in polygon)
				[indices appendFormat:@"%lu ", num.unsignedIntegerValue - 1];
		
		[polylist addChildElementWithName:@"p" stringValue:indices];
	}
	
	// Define a visual scene using the gear
	NSXMLElement *library_visual_scenes = [root addChildElementWithName:@"library_visual_scenes"];
	NSXMLElement *visual_scene = [library_visual_scenes addChildElementWithName:@"visual_scene" attributes:@{ @"id" : @"gearscene" }];
	NSXMLElement *node = [visual_scene addChildElementWithName:@"node"];
	[node addChildElementWithName:@"instance_geometry" attributes:@{ @"url" : @"#gear" }];
	
	NSXMLElement *scene = [root addChildElementWithName:@"scene"];
	[scene addChildElementWithName:@"instance_visual_scene" attributes:@{ @"url" : @"#gearscene" }];
	
	// Finish
	NSXMLDocument *document = [[NSXMLDocument alloc] initWithRootElement:root];
	document.characterEncoding = @"UTF-8";
	[document setStandalone:YES];
	return document;
}

@end
