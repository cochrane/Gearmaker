//
//  NSXMLElement+SimplifiedCreation.h
//  Gearmaker
//
//  Created by Torsten Kammer on 16.04.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSXMLElement (SimplifiedCreation)

- (NSXMLElement *)addChildElementWithName:(NSString *)name;
- (NSXMLElement *)addChildElementWithName:(NSString *)name attributes:(NSDictionary *)attribs;
- (NSXMLElement *)addChildElementWithName:(NSString *)name stringValue:(NSString *)value;

- (void)addAttributeWithName:(NSString *)name stringValue:(NSString *)value;

@end
