//
//  AppDelegate.m
//  Gearmaker
//
//  Created by Torsten Kammer on 27.01.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "AppDelegate.h"

#import "ExportViewController.h"
#import "Gear.h"
#import "Gear3D.h"
#import "Gear3D+ColladaExport.h"
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
	ExportViewController *controller = [[ExportViewController alloc] init];
	savePanel.accessoryView = controller.view;
	controller.panel = savePanel;
	
	[savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
		if (result != NSOKButton) return;
		
		if ([controller.exportType isEqual:@"org.khronos.collada.digital-asset-exchange"])
		{
			NSXMLDocument *doc = [self.gear3D colladaDocumentUsingTriangulation:controller.useTriangulation];
			NSData *data = doc.XMLData;
			
			NSError *error;
			BOOL success = [data writeToURL:savePanel.URL options:NSDataWritingAtomic error:&error];
			if (!success)
				[self.window presentError:error];
		}
		else if ([controller.exportType isEqual:@"com.autodesk.obj"])
		{
			NSString *string = controller.useTriangulation ? [self.gear3D triangulatedObjString] : [self.gear3D objString];
			
			NSError *error;
			BOOL success = [string writeToURL:savePanel.URL atomically:YES encoding:NSASCIIStringEncoding error:&error];
			if (!success)
				[self.window presentError:error];
		}
	}];
}

@end
