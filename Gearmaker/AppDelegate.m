//
//  AppDelegate.m
//  Gearmaker
//
//  Created by Torsten Kammer on 27.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "AppDelegate.h"

#import "Gear.h"
#import "Gear3D.h"
#import "GearView.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.angleNumberFormatter.multiplier = @(180.0 / M_PI);
	
	self.gear = [[Gear alloc] init];
	self.gear.module = 10;
	self.gear.teeth = 30;
	self.gear.eingriffwinkel = 20.0 * M_PI / 180.0;
	self.gear.kopfspielfaktor = 0.25;
	
	self.gear3D = [[Gear3D alloc] init];
	self.gear3D.gear = self.gear;
	self.gear3D.thickness = 1;
	self.gear3D.pointInterval = 0.1;
	
	self.gearView.gear = self.gear;
}

- (IBAction)export:(id)sender;
{
	[self.gearController commitEditing];
	[self.gear3DController commitEditing];
	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	savePanel.canCreateDirectories = YES;
	savePanel.canSelectHiddenExtension = YES;
	savePanel.allowedFileTypes = @[ @"obj" ];
	
	[savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
		if (result != NSOKButton) return;
		
		NSString *text = self.gear3D.objString;
		NSError *error = nil;
		BOOL success = [text writeToURL:savePanel.URL atomically:YES encoding:NSUTF8StringEncoding error:&error];
		if (!success)
			[self.window presentError:error];
	}];
}

@end
