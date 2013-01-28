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
	
	NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:toothFlank.count * 2 * self.teeth];
	
	for (NSUInteger i = 0; i < self.teeth; i++)
	{
		NSAffineTransform *rotate = [NSAffineTransform transform];
		[rotate rotateByRadians:M_PI * 2 * (CGFloat) i / (CGFloat) self.teeth];
		
		NSArray *rotatedToothFlank = [toothFlank map:^(NSValue *point){
			return [NSValue valueWithPoint:[rotate transformPoint:point.pointValue]];
		}];
		
		[points addObjectsFromArray:rotatedToothFlank];
		
		NSAffineTransform *reverseFlankRotate = [NSAffineTransform transform];
		[reverseFlankRotate rotateByRadians:M_PI * 2 * (0.5 + (CGFloat) i) / (CGFloat) self.teeth];
		
		NSArray *rotatedReverseToothFlank = [reverseToothFlank map:^(NSValue *point){
			return [NSValue valueWithPoint:[reverseFlankRotate transformPoint:point.pointValue]];
		}];
		
		[points addObjectsFromArray:rotatedReverseToothFlank];
	}
	
	return [points copy];
}

@end
