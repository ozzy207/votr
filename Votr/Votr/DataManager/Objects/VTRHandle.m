//
//  VTRHandle.m
//  Votr
//
//  Created by Edward Kim on 2/28/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "VTRHandle.h"

@implementation VTRHandle
+ (instancetype)handle:(FIRDatabaseHandle)handle withRef:(FIRDatabaseReference*)ref
{
	VTRHandle *obj = [VTRHandle new];
	[obj setHandle:handle];
	[obj setReference:ref];
	return obj;
}
@end
