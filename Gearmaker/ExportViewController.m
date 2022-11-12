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
    
    _allowedTypes = @[
        [UTType typeWithIdentifier:@"org.khronos.collada.digital-asset-exchange"],
        [UTType typeWithIdentifier:@"org.khronos.collada.digital-asset-exchange"],
        UTTypePDF,
        UTTypeSVG
    ];
	
	_useTriangulation = [[NSUserDefaults standardUserDefaults] boolForKey:@"export-triangulate"];
    NSString *exportTypeIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"export-format"];
	
    _selectedTypeIndex = NSNotFound;
    for (NSUInteger i = 0; i < _allowedTypes.count; i++) {
        if ([exportTypeIdentifier isEqual:_allowedTypes[i].identifier]) {
            _selectedTypeIndex = i;
            break;
        }
    }
	
	return self;
}

- (void)setPanel:(NSSavePanel *)panel
{
	_panel = panel;
    
    self.panel.allowedContentTypes = @[ self.exportType ];
}

- (void)setSelectedTypeIndex:(NSUInteger)selectedTypeIndex
{
	_selectedTypeIndex = selectedTypeIndex;
    _exportType = selectedTypeIndex < _allowedTypes.count ? _allowedTypes[selectedTypeIndex] : nil;
    
    self.panel.allowedContentTypes = @[ self.exportType ];
	
	[[NSUserDefaults standardUserDefaults] setObject:_exportType forKey:@"export-format"];
}

- (void)setUseTriangulation:(BOOL)useTriangulation
{
	_useTriangulation = useTriangulation;
	
	[[NSUserDefaults standardUserDefaults] setBool:_useTriangulation forKey:@"export-triangulate"];
}

- (BOOL)canUseTriangulation
{
    return ![self.exportType isEqual:UTTypePDF];
}

@end
