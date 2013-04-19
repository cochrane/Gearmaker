//
//  Gear+ExportAsPDF.h
//  Gearmaker
//
//  Created by Torsten Kammer on 17.04.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "Gear.h"

@interface Gear (ExportAsPDF)

- (void)writePDFToURL:(NSURL *)url;

@end
