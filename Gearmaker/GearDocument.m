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
#import "Gear.h"
#import "Gear3D+ColladaExport.h"
#import "Gear+ExportAsPDF.h"
#import "Gear+ExportAsSVG.h"
#import "GearView.h"

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
	NSDictionary *data = @{
	@"modul" : @(self.gear.module),
	@"zaehne" : @(self.gear.teeth),
	@"eingriffwinkel" : @(self.gear.eingriffwinkel),
	@"kopfspielfaktor" : @(self.gear.kopfspielfaktor),
	@"dicke" : @(self.gear.thickness),
	@"pointInterval" : @(self.gear.pointInterval)
	};
	
	return [NSPropertyListSerialization dataWithPropertyList:data format:NSPropertyListXMLFormat_v1_0 options:0 error:outError];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:outError];
	if (!dict) return NO;
	
	if (!dict[@"zaehne"] || !dict[@"modul"] || !dict[@"kopfspielfaktor"] || !dict[@"eingriffwinkel"] || !dict[@"dicke"] || !dict[@"pointInterval"])
	{
		if (outError)
			*outError = [NSError errorWithDomain:@"GearDocument" code:1 userInfo:@{
					  NSLocalizedDescriptionKey : NSLocalizedString(@"Dem Dokument fehlen wichtige Daten.", @"not all keys present in file - description"),
					  NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Das Dokument ist beschädigt oder in einem Format, dass Gearmaker nicht erkennt.", @"not all keys present in file - recovery suggestion"),
						 }];
		return NO;
	}
	
	self.gear.module = [dict[@"modul"] doubleValue];
	self.gear.teeth = [dict[@"zaehne"] unsignedIntegerValue];
	self.gear.eingriffwinkel = [dict[@"eingriffwinkel"] doubleValue];
	self.gear.kopfspielfaktor = [dict[@"kopfspielfaktor"] doubleValue];
    self.gear.pointInterval = [dict[@"pointInterval"] doubleValue];
	
	self.gear.thickness = [dict[@"dicke"] doubleValue];
	
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
		
		if ([controller.exportType isEqual:@"org.khronos.collada.digital-asset-exchange"])
		{
			NSXMLDocument *doc = [self.gear colladaDocumentUsingTriangulation:controller.useTriangulation];
			NSData *data = doc.XMLData;
			
			NSError *error;
			BOOL success = [data writeToURL:savePanel.URL options:NSDataWritingAtomic error:&error];
			if (!success)
				[self.windowForSheet presentError:error];
		}
		else if ([controller.exportType isEqual:@"com.autodesk.obj"])
		{
			NSString *string = controller.useTriangulation ? [self.gear triangulatedObjString] : [self.gear objString];
			
			NSError *error;
			BOOL success = [string writeToURL:savePanel.URL atomically:YES encoding:NSASCIIStringEncoding error:&error];
			if (!success)
				[self.windowForSheet presentError:error];
		}
		else if ([controller.exportType isEqual:[UTTypePDF identifier]])
        {
            NSError *error;
            BOOL success = [self.gear writePDFToURL:savePanel.URL error:&error];
			if (!success)
				[self.windowForSheet presentError:error];
		}
        else if ([controller.exportType isEqual:[UTTypeSVG identifier]])
        {
            NSError *error;
            BOOL success = [self.gear writeSVGToURL:savePanel.URL error:&error];
            if (!success)
                [self.windowForSheet presentError:error];
        }
	}];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

@end
