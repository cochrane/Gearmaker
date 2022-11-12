//
//  ExportViewController.h
//  Gearmaker
//
//  Created by Torsten Kammer on 16.04.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface ExportViewController : NSViewController

@property (nonatomic, readonly) BOOL canUseTriangulation;
@property (nonatomic) BOOL useTriangulation;
@property (nonatomic) NSUInteger selectedTypeIndex;

@property (nonatomic, readonly) NSArray<UTType*>* allowedTypes;
@property (nonatomic, readonly) UTType *exportType;

@property (nonatomic, weak) NSSavePanel *panel;

@end
