//
//  AppDelegate.h
//  Gearmaker
//
//  Created by Torsten Kammer on 27.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Gear;
@class Gear3D;
@class GearView;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet GearView *gearView;
@property (assign) IBOutlet NSObjectController *gearController;
@property (assign) IBOutlet NSObjectController *gear3DController;
@property (nonatomic) Gear *gear;
@property (nonatomic) Gear3D *gear3D;

- (IBAction)export:(id)sender;

@end
