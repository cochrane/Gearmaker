//
//  Involute.m
//  Gearmaker
//
//  Created by Torsten Kammer on 27.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "Involute.h"

@implementation Involute

- (CGPoint)pointAt:(CGFloat)angleInRad;
{
	CGFloat s = angleInRad * self.baseCircleRadius;
	
	CGPoint circumferencePoint = (CGPoint) {
		self.baseCircleRadius * cos(angleInRad),
		self.baseCircleRadius * sin(angleInRad)
	};
	
	return (CGPoint) {
		circumferencePoint.x + s*sin(angleInRad),
		circumferencePoint.y - s*cos(angleInRad)
	};
}

- (CGFloat)angleForIntersectionWithCircleRadius:(CGFloat)outerRadius;
{
	CGFloat relativeRadius = outerRadius;
	CGFloat ratio = relativeRadius / self.baseCircleRadius;
	return sqrt(ratio * ratio - 1);
}

- (CGPoint)tangentAt:(CGFloat)angleInRad;
{
	return (CGPoint) {
		cos(angleInRad),
		sin(angleInRad)
	};
}

@end
