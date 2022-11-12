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

@property (nonatomic) CGFloat thickness;

@property (nonatomic, readonly) NSString *objString;
@property (nonatomic, readonly) NSString *triangulatedObjString;

@property (nonatomic, readonly) NSArray *vertices; // array of nsvalues of three floats
@property (nonatomic, readonly) NSArray *polygons; // contains arrays with indices into vertices (+1)
@property (nonatomic, readonly) NSArray *triangulatedElements; // contains indices into vertices (+1)

- (NSArray *)getToothFlankPointsAtIntervals:(CGFloat)interval;
- (NSArray *)getOutlinePointsAtInveral:(CGFloat)interval;

- (BOOL)loadFrom:(NSData *)data error:(NSError *__autoreleasing*)error;

@end
