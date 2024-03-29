//
//  GearDocument.h
//  Gearmaker
//
//  Created by Torsten Kammer on 16.04.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Gear;
@class Gear3D;
@class GearView;

@interface GearDocument : NSDocument

@property (assign) IBOutlet GearView *gearView;
@property (assign) IBOutlet NSObjectController *gearController;
@property (assign) IBOutlet NSNumberFormatter *angleNumberFormatter;
@property (nonatomic) Gear *gear;

- (IBAction)export:(id)sender;

@end
