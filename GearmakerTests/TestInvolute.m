//
//  TestInvolute.m
//  Gearmaker
//
//  Created by Torsten Kammer on 27.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "TestInvolute.h"

#import "Involute.h"

@implementation TestInvolute

- (void)testUnitCircle
{
	Involute *curve = [[Involute alloc] init];
	
	curve.origin = CGPointZero;
	curve.baseCircleRadius = 1.0;
	
	CGPoint first = [curve pointAt:0.0];
	STAssertEqualsWithAccuracy(first.x, 1.0, 1e-4, @"First x is wrong");
	STAssertEqualsWithAccuracy(first.y, 0.0, 1e-4, @"First y is wrong");
	
	CGPoint atPi = [curve pointAt:M_PI];
	STAssertEqualsWithAccuracy(atPi.x, -1.0, 1e-2, @"Point at π x is wrong");
	STAssertEqualsWithAccuracy(atPi.y, M_PI, 1e-2, @"Point at π y is wrong");
}

- (void)testLargerCircle
{
	Involute *curve = [[Involute alloc] init];
	
	curve.origin = CGPointZero;
	curve.baseCircleRadius = 2.0;
	
	CGPoint first = [curve pointAt:0.0];
	STAssertEqualsWithAccuracy(first.x, 2.0, 1e-4, @"First x is wrong");
	STAssertEqualsWithAccuracy(first.y, 0.0, 1e-4, @"First y is wrong");
	
	CGPoint atPi = [curve pointAt:M_PI];
	STAssertEqualsWithAccuracy(atPi.x, -2.0, 1e-2, @"Point at π x is wrong");
	STAssertEqualsWithAccuracy(atPi.y, 2.0 * M_PI, 1e-2, @"Point at π y is wrong");
}

- (void)testSmallerCircle
{
	Involute *curve = [[Involute alloc] init];
	
	curve.origin = CGPointZero;
	curve.baseCircleRadius = .5;
	
	CGPoint first = [curve pointAt:0.0];
	STAssertEqualsWithAccuracy(first.x, 0.5, 1e-4, @"First x is wrong");
	STAssertEqualsWithAccuracy(first.y, 0.0, 1e-4, @"First y is wrong");
	
	CGPoint atPi = [curve pointAt:M_PI];
	STAssertEqualsWithAccuracy(atPi.x, -0.5, 1e-2, @"Point at π x is wrong");
	STAssertEqualsWithAccuracy(atPi.y, 0.5 * M_PI, 1e-2, @"Point at π y is wrong");
}

- (void)testTangentUnit
{
	Involute *curve = [[Involute alloc] init];
	
	curve.origin = CGPointZero;
	curve.baseCircleRadius = 1;
	
	CGPoint first = [curve tangentAt:0.0];
	STAssertEqualsWithAccuracy(first.x, 1.0, 1e-4, @"First x is wrong");
	STAssertEqualsWithAccuracy(first.y, 0.0, 1e-4, @"First y is wrong");
	
	CGPoint atHalfPi = [curve tangentAt:M_PI_2];
	STAssertEqualsWithAccuracy(atHalfPi.x, 0.0, 1e-2, @"Tangent at π/2 x is wrong");
	STAssertEqualsWithAccuracy(atHalfPi.y, 1.0, 1e-2, @"Tangent at π y/2 is wrong");
	
	CGPoint atPi = [curve tangentAt:M_PI];
	STAssertEqualsWithAccuracy(atPi.x, -1.0, 1e-2, @"Tangent at π x is wrong");
	STAssertEqualsWithAccuracy(atPi.y, 0.0, 1e-2, @"Tangent at π y is wrong");
}

- (void)testAngleForCircle
{
	Involute *curve = [[Involute alloc] init];
	
	curve.origin = CGPointZero;
	curve.baseCircleRadius = 1.0;
	
	STAssertFalse(isnan([curve angleForIntersectionWithCircleRadius:1.0]), @"Should not return nan");
	STAssertEqualsWithAccuracy([curve angleForIntersectionWithCircleRadius:1.0], 0.0, 1e-4, @"wrong angle");
	
	STAssertFalse(isnan([curve angleForIntersectionWithCircleRadius:1.5]), @"Should not return nan");
	STAssertEqualsWithAccuracy([curve angleForIntersectionWithCircleRadius:1.5], 1.1180, 1e-2, @"wrong angle");
	
	STAssertFalse(isnan([curve angleForIntersectionWithCircleRadius:2.0]), @"Should not return nan");
	STAssertEqualsWithAccuracy([curve angleForIntersectionWithCircleRadius:2.0], 1.732, 1e-2, @"wrong angle");
}

@end
