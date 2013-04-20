//
//  GenerateGearImage.m
//  Gearmaker
//
//  Created by Torsten Kammer on 20.04.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GenerateGearImage.h"
#import "Gear.h"

_Bool GenerateGearImage(CGContextRef context, CGSize size, CFURLRef url)
{
	@autoreleasepool
	{
		NSData *data = [NSData dataWithContentsOfURL:(__bridge NSURL *)url];
		if (!data) return false;
		NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:NULL];
		if (!dict) return false;
		
		if (!dict[@"zaehne"] || !dict[@"modul"] || !dict[@"kopfspielfaktor"] || !dict[@"eingriffwinkel"] || !dict[@"dicke"] || !dict[@"pointInterval"])
			return false;
		
		Gear *gear = [[Gear alloc] init];
		
		gear.module = [dict[@"modul"] doubleValue];
		gear.teeth = [dict[@"zaehne"] unsignedIntegerValue];
		gear.eingriffwinkel = [dict[@"eingriffwinkel"] doubleValue];
		gear.kopfspielfaktor = [dict[@"kopfspielfaktor"] doubleValue];
		
		NSArray *outlinePoints = [gear getOutlinePointsAtInveral:1.0];
		
		// Prepare translation
		CGContextTranslateCTM(context, size.width * 0.5, size.height * 0.5);
		
		// Scale
		CGFloat diameter = gear.kopfkreisdurchmesser * 1.05;
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
	return true;
}
