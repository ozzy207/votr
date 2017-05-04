//
//  VTRComment.m
//  Votr
//
//  Created by Edward Kim on 2/25/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "VTRComment.h"

@implementation VTRComment

- (NSMutableDictionary*)dictionaryRepresentation
{
	NSMutableDictionary *mDictionary = [super dictionaryRepresentation];
	
	if (self.owner) {
		[mDictionary setObject:self.owner forKey:@"owner"];
	}
	
	if (self.message) {
		[mDictionary setObject:self.message forKey:@"message"];
	}
	
	if (self.likes){
		[mDictionary setObject:self.likes forKey:@"likes"];
	}

	return mDictionary;
}
@end
