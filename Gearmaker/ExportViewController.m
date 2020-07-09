//
//  ExportViewController.m
//  Gearmaker
//
//  Created by Torsten Kammer on 16.04.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "ExportViewController.h"

@interface ExportViewController ()

@end

@implementation ExportViewController

+ (NSSet *)keyPathsForValuesAffectingCanUseTriangulation
{
	return [NSSet setWithObjects:@"selectedTypeIndex", nil];
}

- (id)init
{
	if (!(self = [super initWithNibName:[self className] bundle:nil]))
		return nil;

	[[NSUserDefaults standardUserDefaults] registerDefaults:@{
	 @"export-triangulate": @(YES),
	 @"export-format" : @"org.khronos.collada.digital-asset-exchange"
	 }];
	
	_useTriangulation = [[NSUserDefaults standardUserDefaults] boolForKey:@"export-triangulate"];
	_exportType = [[NSUserDefaults standardUserDefaults] stringForKey:@"export-format"];
	
	if ([_exportType isEqual:@"org.khronos.collada.digital-asset-exchange"])
		_selectedTypeIndex = 0;
	else if ([_exportType isEqual:@"com.autodesk.obj"])
		_selectedTypeIndex = 1;
	else if ([_exportType isEqual:(__bridge NSString *)kUTTypePDF])
		_selectedTypeIndex = 2;
    else if ([_exportType isEqual:(__bridge NSString *)kUTTypeScalableVectorGraphics])
        _selectedTypeIndex = 3;
	else
		_selectedTypeIndex = NSNotFound;
	
	return self;
}

- (void)setPanel:(NSSavePanel *)panel
{
	_panel = panel;
	
	_panel.allowedFileTypes = @[ self.exportType ];
}

- (void)setSelectedTypeIndex:(NSUInteger)selectedTypeIndex
{
	_selectedTypeIndex = selectedTypeIndex;
	
	if (_selectedTypeIndex == 0)
		_exportType = @"org.khronos.collada.digital-asset-exchange";
	else if (_selectedTypeIndex == 1)
		_exportType = @"com.autodesk.obj";
        else if (_selectedTypeIndex == 2)
            _exportType = (__bridge NSString *)kUTTypePDF;
    else if (_selectedTypeIndex == 3)
        _exportType = (__bridge NSString *)kUTTypeScalableVectorGraphics;
	else
		_exportType = nil;
	
	self.panel.allowedFileTypes = @[ _exportType ];
	
	[[NSUserDefaults standardUserDefaults] setObject:_exportType forKey:@"export-format"];
}

- (void)setUseTriangulation:(BOOL)useTriangulation
{
	_useTriangulation = useTriangulation;
	
	[[NSUserDefaults standardUserDefaults] setBool:_useTriangulation forKey:@"export-triangulate"];
}

- (BOOL)canUseTriangulation
{
	return ![self.exportType isEqual:(__bridge NSString *) kUTTypePDF];
}

@end
