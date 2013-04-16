//
//  Gear3D+ColladaExport.h
//  Gearmaker
//
//  Created by Torsten Kammer on 16.04.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "Gear3D.h"

@interface Gear3D (ColladaExport)

- (NSXMLDocument *)colladaDocumentUsingTriangulation:(BOOL)triangulate;

@end
