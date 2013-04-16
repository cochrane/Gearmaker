//
//  NSXMLElement+SimplifiedCreation.m
//  Gearmaker
//
//  Created by Torsten Kammer on 16.04.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import "NSXMLElement+SimplifiedCreation.h"

@implementation NSXMLElement (SimplifiedCreation)

- (NSXMLElement *)addChildElementWithName:(NSString *)name;
{
	NSXMLElement *element = [[self class] elementWithName:name];
	[self addChild:element];
	return element;
}
- (NSXMLElement *)addChildElementWithName:(NSString *)name attributes:(NSDictionary *)attribs;
{
	NSXMLElement *element = [self addChildElementWithName:name];
	
	for (NSString *key in attribs)
		[element addAttributeWithName:key stringValue:[attribs[key] isKindOfClass:[NSString class]] ? attribs[key] : [attribs[key] stringValue]];
	
	return element;
}
- (NSXMLElement *)addChildElementWithName:(NSString *)name stringValue:(NSString *)value;
{
	NSXMLElement *element = [[self class] elementWithName:name stringValue:value];
	[self addChild:element];
	return element;
}

- (void)addAttributeWithName:(NSString *)name stringValue:(NSString *)value;
{
	[self addAttribute:[NSXMLNode attributeWithName:name stringValue:value]];
}

@end
