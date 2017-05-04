//
//  VTRTag.m
//  Votr
//
//  Created by Edward Kim on 1/26/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "VTRTag.h"

@implementation VTRTag

- (NSMutableDictionary*)dictionaryRepresentation
{
	NSMutableDictionary *mDictionary = [super dictionaryRepresentation];
	
	if(self.posts){
		[mDictionary setObject:self.posts forKey:@"posts"];
	}
	
	return mDictionary;
	
}

@end
