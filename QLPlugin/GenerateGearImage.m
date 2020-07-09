//
//  GenerateGearImage.m
//  Gearmaker
//
//  Created by Torsten Kammer on 20.04.13.
//  Copyright (c) 2013 Torsten Kammer. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GenerateGearImage.h"
#import "Gear.h"
#import "Gear+ExportAsPDF.h"

_Bool GenerateGearImage(CGContextRef context, CGSize size, CFURLRef url)
{
	@autoreleasepool
	{
		NSData *data = [NSData dataWithContentsOfURL:(__bridge NSURL *)url];
		if (!data) return false;
		NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:NULL];
		if (!dict) return false;
		
		if (!dict[@"zaehne"] || !dict[@"modul"] || !dict[@"kopfspielfaktor"] || !dict[@"eingriffwinkel"] || !dict[@"dicke"] || !dict[@"pointInterval"])
			return false;
		
		Gear *gear = [[Gear alloc] init];
		
		gear.module = [dict[@"modul"] doubleValue];
		gear.teeth = [dict[@"zaehne"] unsignedIntegerValue];
		gear.eingriffwinkel = [dict[@"eingriffwinkel"] doubleValue];
		gear.kopfspielfaktor = [dict[@"kopfspielfaktor"] doubleValue];
        gear.pointInterval = [dict[@"pointInterval"] doubleValue];
		
		[gear drawInContext:context size:size];
	}
	return true;
}
