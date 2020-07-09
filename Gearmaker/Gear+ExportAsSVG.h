//
//  Gear+ExportAsSVG.h
//  Gearmaker
//
//  Created by Torsten Kammer on 08.07.20.
//  Copyright © 2020 Torsten Kammer. All rights reserved.
//

#import "Gear.h"

NS_ASSUME_NONNULL_BEGIN

@interface Gear (ExportAsSVG)

- (BOOL)writeSVGToURL:(NSURL *)url error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
