//
//  GearDocument.m
//  Gearmaker
//
//  Created by Torsten Kammer on 16.04.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "GearDocument.h"

#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#import "ExportViewController.h"

#import "Gearmaker-Swift.h"

@implementation GearDocument

- (id)init
{
    if (!(self = [super init])) return nil;
	
	self.gear = [[Gear alloc] init];
	self.gear.module = 10;
	self.gear.teeth = 30;
	self.gear.eingriffwinkel = 20.0 * M_PI / 180.0;
	self.gear.kopfspielfaktor = 0.25;
    self.gear.pointInterval = 0.1;
    self.gear.thickness = 20;
	
    return self;
}

- (NSString *)windowNibName
{
    return @"GearDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
	
	self.angleNumberFormatter.multiplier = @(180.0 / M_PI);
	
	self.gearView.gear = self.gear;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    return [self.gear writeDataAndReturnError:outError];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    self.gear = [Gear loadFromData:data error:outError];
    if (!self.gear) {
        return NO;
    }
    
    if (self.gearView) {
        self.gearView.gear = self.gear;
    }
    
    return YES;
}

- (IBAction)export:(id)sender;
{
	[self.gearController commitEditing];
	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	savePanel.canCreateDirectories = YES;
	savePanel.canSelectHiddenExtension = YES;
	ExportViewController *controller = [[ExportViewController alloc] init];
	savePanel.accessoryView = controller.view;
	controller.panel = savePanel;
	
	[savePanel beginSheetModalForWindow:self.windowForSheet completionHandler:^(NSInteger result){
		if (result != NSModalResponseOK) return;
        
        NSError *error = [NSError errorWithDomain:@"Gearmaker" code:-1 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"File type not supported", @"Default in case file cannot be written")}];
        BOOL success = false;
		if ([controller.exportType.identifier isEqual:@"org.khronos.collada.digital-asset-exchange"])
		{
            success = [self.gear writeColladaTo:savePanel.URL triangulate:controller.useTriangulation error:&error];
		}
		else if ([controller.exportType.identifier isEqual:@"com.autodesk.obj"])
		{
            success = [self.gear writeOBJTo:savePanel.URL triangulate:controller.useTriangulation error:&error];
		}
		else if ([controller.exportType isEqual:UTTypePDF])
        {
            success = [self.gear writePDFTo:savePanel.URL error:&error];
		}
        else if ([controller.exportType isEqual:UTTypeSVG])
        {
            success = [self.gear writeSVGTo:savePanel.URL error:&error];
        }
        if (!success)
            [self.windowForSheet presentError:error];
	}];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

@end
