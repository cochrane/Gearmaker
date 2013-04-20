//
//  GearView.m
//  Gearmaker
//
//  Created by Torsten Kammer on 28.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "GearView.h"

#import "Gear.h"

@interface GearView ()

@property (nonatomic) NSArray *outlinePoints;

@end

@implementation GearView

- (id)initWithFrame:(NSRect)frame
{
	if (!(self = [super initWithFrame:frame])) return nil;
    
	[self addObserver:self forKeyPath:@"gear.module" options:NSKeyValueObservingOptionNew context:0];
	[self addObserver:self forKeyPath:@"gear.teeth" options:NSKeyValueObservingOptionNew context:0];
	[self addObserver:self forKeyPath:@"gear.eingriffwinkel" options:NSKeyValueObservingOptionNew context:0];
	[self addObserver:self forKeyPath:@"gear.kopfspielfaktor" options:NSKeyValueObservingOptionNew context:0];
	
    return self;
}

- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"gear.module"];
	[self removeObserver:self forKeyPath:@"gear.teeth"];
	[self removeObserver:self forKeyPath:@"gear.eingriffwinkel"];
	[self removeObserver:self forKeyPath:@"gear.kopfspielfaktor"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	self.outlinePoints = [self.gear getOutlinePointsAtInveral:1.0];
	self.needsDisplay = YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
	// Clear
	[[NSColor whiteColor] set];
	NSBezierPath *rectPath = [NSBezierPath bezierPathWithRect:dirtyRect];
	[rectPath fill];
	
	if (self.outlinePoints.count == 0) return;
	
	// Prepare translation
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform translateXBy:NSMidX(self.bounds) yBy:NSMidY(self.bounds)];
	
	// Draw teilkreis
	[[NSColor redColor] set];
	CGFloat teilkreisRadius = self.gear.teilkreisdurchmesser * 0.5;
	NSBezierPath *teilkreisPath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(-teilkreisRadius, -teilkreisRadius, teilkreisRadius*2., teilkreisRadius*2.)];
	[[transform transformBezierPath:teilkreisPath] stroke];
	
	// Draw gear
	[[NSColor blackColor] set];
	NSBezierPath *gearPath = [NSBezierPath bezierPath];
	[gearPath moveToPoint:[self.outlinePoints[0] pointValue]];
	for (NSValue *point in self.outlinePoints)
		[gearPath lineToPoint:point.pointValue];
	[gearPath closePath];
	[[transform transformBezierPath:gearPath] stroke];
}

@end
