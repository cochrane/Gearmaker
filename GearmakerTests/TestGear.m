//
//  TestGear.m
//  Gearmaker
//
//  Created by Torsten Kammer on 28.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "TestGear.h"

#import "Gear.h"

@implementation TestGear

- (void)testGear
{
	Gear *gear = [[Gear alloc] init];
	gear.module = 3.0;
	gear.teeth = 20;
	gear.eingriffwinkel = 20.0 * M_PI / 180.0;
	gear.kopfspielfaktor = 0.25;
	
	XCTAssertEqualWithAccuracy(gear.kopfhoehe, 3.0, 1e-3, @"Falsche Kopfhöhe");
	XCTAssertEqualWithAccuracy(gear.kopfspiel, 0.75, 1e-3, @"Falsches Kopfspiel");
	XCTAssertEqualWithAccuracy(gear.fusshoehe, 3.75, 1e-3, @"Falsche Fußhöhe");
	XCTAssertEqualWithAccuracy(gear.fusskreisdurchmesser, 52.5, 1e-3, @"Falsches Kopfspiel");
	XCTAssertEqualWithAccuracy(gear.grundkreisdurchmesser, 56.382, 1e-3, @"Falsches Kopfspiel");
	XCTAssertEqualWithAccuracy(gear.teilkreisdurchmesser, 60.0, 1e-3, @"Falsches Kopfspiel");
	XCTAssertEqualWithAccuracy(gear.kopfkreisdurchmesser, 66.0, 1e-3, @"Falsches Kopfspiel");
}

- (void)testTooth
{
	Gear *gear = [[Gear alloc] init];
	gear.module = 3.0;
	gear.teeth = 20;
	gear.eingriffwinkel = 20.0 * M_PI / 180.0;
	gear.kopfspielfaktor = 0.25;
	
	NSArray *points = [gear getToothFlankPointsAtIntervals:0.1];
	XCTAssertNotNil(points, @"Did not generate points");
	XCTAssertTrue(points.count > 0, @"Did not generate points");
	
	XCTAssertEqualWithAccuracy([points[0] pointValue].x, 26.25, 1e-3, @"Foot circle x");
	XCTAssertEqualWithAccuracy([points[0] pointValue].y, 0.0, 1e-3, @"Foot circle y");
	
	XCTAssertEqualWithAccuracy([points[1] pointValue].x, 28.191, 1e-3, @"Base circle x");
	XCTAssertEqualWithAccuracy([points[1] pointValue].y, 0.0, 1e-3, @"Base circle y");
	
	XCTAssertEqualWithAccuracy([points.lastObject pointValue].x, 32.9369, 1e-3, @"Outer circle x");
	XCTAssertEqualWithAccuracy([points.lastObject pointValue].y, 2.0399, 1e-3, @"Outer circle y");
}

@end
