//
//  BTRVote.m
//  Votr
//
//  Created by Edward Kim on 2/25/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "VTRVote.h"

@implementation VTRVote

- (NSMutableDictionary*)dictionaryRepresentation
{
	NSMutableDictionary *mDictionary = [super dictionaryRepresentation];
	
	if (self.owner){
		[mDictionary setObject:self.owner forKey:@"owner"];
	}
	
	if (self.selectedIndex){
		[mDictionary setObject:self.selectedIndex forKey:@"selectedIndex"];
	}

	return mDictionary;
}

@end
