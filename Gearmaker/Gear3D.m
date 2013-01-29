//
//  Gear3D.m
//  Gearmaker
//
//  Created by Torsten Kammer on 28.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "Gear3D.h"

#import "Gear.h"

@implementation Gear3D

- (NSString *)objString
{
	NSArray *outline = [self.gear getOutlinePointsAtInveral:self.pointInterval];
	
	NSMutableString *output = [NSMutableString stringWithString:@"# Created with Gearmaker by Torsten Kammer\n"];
	
	CGFloat halfWidth = self.thickness * 0.5;
	
	// Print vertices on top
	for (NSValue *value in outline)
	{
		NSPoint point = value.pointValue;
		[output appendFormat:@"v %.6f %.6f %.6f\n", point.x, halfWidth, point.y];
	}
	[output appendString:@"\n"];
	
	// Print vertices below
	for (NSValue *value in outline)
	{
		NSPoint point = value.pointValue;
		[output appendFormat:@"v %.6f %.6f %.6f\n", point.x, -halfWidth, point.y];
	}
	[output appendString:@"\n"];
	
	// Add wall faces
	for (NSUInteger i = 0; i < outline.count; i++)
		[output appendFormat:@"f %lu %lu %lu %lu\n", (i%outline.count)+1, ((i)%outline.count)+outline.count+1, ((i+1)%outline.count)+outline.count+1, ((i+1)%outline.count)+1];
	
	// Add tooth faces
	NSUInteger pointsPerTeeth = outline.count / self.gear.teeth;
	for (NSUInteger i = 0; i < self.gear.teeth; i++)
	{
		// Above
		[output appendFormat:@"\nf "];
		for (NSUInteger j = 1; j <= pointsPerTeeth; j++)
			[output appendFormat:@"%lu ", j + i*pointsPerTeeth];
		
		// Below - reverse for correct face winding
		[output appendFormat:@"\nf "];
		for (NSUInteger j = pointsPerTeeth; j > 0; j--)
			[output appendFormat:@"%lu ", j + i*pointsPerTeeth + outline.count];
	}
	
	// Add central face - top
	[output appendFormat:@"\n\nf "];
	for (NSUInteger i = 0; i < self.gear.teeth; i++)
	{
		[output appendFormat:@"%lu %lu ", i*pointsPerTeeth+1, (i+1)*pointsPerTeeth];
	}
	
	// Central face - bottom
	[output appendFormat:@"\n\nf "];
	for (NSUInteger i = 0; i < self.gear.teeth; i++)
	{
		[output appendFormat:@"%lu %lu ", i*pointsPerTeeth+1 + outline.count, (i+1)*pointsPerTeeth + outline.count];
	}
	
	return [output copy];
}

@end
