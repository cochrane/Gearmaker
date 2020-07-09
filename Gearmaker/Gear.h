//
//  Gear.h
//  Gearmaker
//
//  Created by Torsten Kammer on 28.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gear : NSObject

// This class uses translated german terms, according to DIN, which may be different from the standards used in the US or UK.

@property (nonatomic) CGFloat module;
@property (nonatomic) NSUInteger teeth;
@property (nonatomic) CGFloat kopfspielfaktor;
@property (nonatomic) CGFloat eingriffwinkel;

@property (nonatomic, readonly) CGFloat kopfhoehe;
@property (nonatomic, readonly) CGFloat fusshoehe;
@property (nonatomic, readonly) CGFloat kopfspiel;
@property (nonatomic, readonly) CGFloat teilkreisdurchmesser;
@property (nonatomic, readonly) CGFloat kopfkreisdurchmesser;
@property (nonatomic, readonly) CGFloat fusskreisdurchmesser;
@property (nonatomic, readonly) CGFloat grundkreisdurchmesser;

@property (nonatomic) CGFloat pointInterval;

- (NSArray *)getToothFlankPointsAtIntervals:(CGFloat)interval;
- (NSArray *)getOutlinePointsAtInveral:(CGFloat)interval;

@end
