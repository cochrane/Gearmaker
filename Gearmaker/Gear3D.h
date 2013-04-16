//
//  Gear3D.h
//  Gearmaker
//
//  Created by Torsten Kammer on 28.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Gear;

@interface Gear3D : NSObject

@property (nonatomic) Gear *gear;

@property (nonatomic) CGFloat thickness;
@property (nonatomic) CGFloat pointInterval;

@property (nonatomic, readonly) NSString *objString;
@property (nonatomic, readonly) NSString *triangulatedObjString;

@property (nonatomic, readonly) NSArray *vertices; // array of nsvalues of three floats
@property (nonatomic, readonly) NSArray *polygons; // contains arrays with indices into vertices (+1)
@property (nonatomic, readonly) NSArray *triangulatedElements; // contains indices into vertices (+1)

@end
