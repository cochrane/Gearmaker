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
	XCTAssertEqualWithAccuracy(first.x, 1.0, 1e-4, @"First x is wrong");
	XCTAssertEqualWithAccuracy(first.y, 0.0, 1e-4, @"First y is wrong");
	
	CGPoint atPi = [curve pointAt:M_PI];
	XCTAssertEqualWithAccuracy(atPi.x, -1.0, 1e-2, @"Point at π x is wrong");
	XCTAssertEqualWithAccuracy(atPi.y, M_PI, 1e-2, @"Point at π y is wrong");
}

- (void)testLargerCircle
{
	Involute *curve = [[Involute alloc] init];
	
	curve.origin = CGPointZero;
	curve.baseCircleRadius = 2.0;
	
	CGPoint first = [curve pointAt:0.0];
	XCTAssertEqualWithAccuracy(first.x, 2.0, 1e-4, @"First x is wrong");
	XCTAssertEqualWithAccuracy(first.y, 0.0, 1e-4, @"First y is wrong");
	
	CGPoint atPi = [curve pointAt:M_PI];
	XCTAssertEqualWithAccuracy(atPi.x, -2.0, 1e-2, @"Point at π x is wrong");
	XCTAssertEqualWithAccuracy(atPi.y, 2.0 * M_PI, 1e-2, @"Point at π y is wrong");
}

- (void)testSmallerCircle
{
	Involute *curve = [[Involute alloc] init];
	
	curve.origin = CGPointZero;
	curve.baseCircleRadius = .5;
	
	CGPoint first = [curve pointAt:0.0];
	XCTAssertEqualWithAccuracy(first.x, 0.5, 1e-4, @"First x is wrong");
	XCTAssertEqualWithAccuracy(first.y, 0.0, 1e-4, @"First y is wrong");
	
	CGPoint atPi = [curve pointAt:M_PI];
	XCTAssertEqualWithAccuracy(atPi.x, -0.5, 1e-2, @"Point at π x is wrong");
	XCTAssertEqualWithAccuracy(atPi.y, 0.5 * M_PI, 1e-2, @"Point at π y is wrong");
}

- (void)testTangentUnit
{
	Involute *curve = [[Involute alloc] init];
	
	curve.origin = CGPointZero;
	curve.baseCircleRadius = 1;
	
	CGPoint first = [curve tangentAt:0.0];
	XCTAssertEqualWithAccuracy(first.x, 1.0, 1e-4, @"First x is wrong");
	XCTAssertEqualWithAccuracy(first.y, 0.0, 1e-4, @"First y is wrong");
	
	CGPoint atHalfPi = [curve tangentAt:M_PI_2];
	XCTAssertEqualWithAccuracy(atHalfPi.x, 0.0, 1e-2, @"Tangent at π/2 x is wrong");
	XCTAssertEqualWithAccuracy(atHalfPi.y, 1.0, 1e-2, @"Tangent at π y/2 is wrong");
	
	CGPoint atPi = [curve tangentAt:M_PI];
	XCTAssertEqualWithAccuracy(atPi.x, -1.0, 1e-2, @"Tangent at π x is wrong");
	XCTAssertEqualWithAccuracy(atPi.y, 0.0, 1e-2, @"Tangent at π y is wrong");
}

- (void)testAngleForCircle
{
	Involute *curve = [[Involute alloc] init];
	
	curve.origin = CGPointZero;
	curve.baseCircleRadius = 1.0;
	
	XCTAssertFalse(isnan([curve angleForIntersectionWithCircleRadius:1.0]), @"Should not return nan");
	XCTAssertEqualWithAccuracy([curve angleForIntersectionWithCircleRadius:1.0], 0.0, 1e-4, @"wrong angle");
	
	XCTAssertFalse(isnan([curve angleForIntersectionWithCircleRadius:1.5]), @"Should not return nan");
	XCTAssertEqualWithAccuracy([curve angleForIntersectionWithCircleRadius:1.5], 1.1180, 1e-2, @"wrong angle");
	
	XCTAssertFalse(isnan([curve angleForIntersectionWithCircleRadius:2.0]), @"Should not return nan");
	XCTAssertEqualWithAccuracy([curve angleForIntersectionWithCircleRadius:2.0], 1.732, 1e-2, @"wrong angle");
}

@end
