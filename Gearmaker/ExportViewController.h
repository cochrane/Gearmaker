//
//  ExportViewController.h
//  Gearmaker
//
//  Created by Torsten Kammer on 16.04.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ExportViewController : NSViewController

@property (nonatomic) BOOL useTriangulation;
@property (nonatomic) NSUInteger selectedTypeIndex;

@property (nonatomic, readonly) NSString *exportType;

@property (nonatomic, weak) NSSavePanel *panel;

@end
