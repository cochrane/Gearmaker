//
//  Involute.h
//  Gearmaker
//
//  Created by Torsten Kammer on 27.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Involute : NSObject

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat baseCircleRadius;

- (CGPoint)pointAt:(CGFloat)angleInRad;

- (CGFloat)angleForIntersectionWithCircleRadius:(CGFloat)outerRadius;

- (CGPoint)tangentAt:(CGFloat)angleInRad;

@end
