//
//  VTRPollItem.m
//  Votr
//
//  Created by Edward Kim on 1/19/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "VTRPostItem.h"

@implementation VTRPostItem

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"url"]) {
		self.url = [NSURL URLWithString:value];
		return;
	}
	
	[super setValue:value forKey:key];
}

- (NSMutableDictionary*)dictionaryRepresentation
{
	NSMutableDictionary *mDictionary = [super dictionaryRepresentation];
	
	if (self.url){
		[mDictionary setObject:[self.url absoluteString] forKey:@"url"];
	}
	
//	if (self.voters) {
//		[mDictionary setObject:self.voters forKey:@"voters"];
//	}
	
	if (self.path) {
		[mDictionary setObject:self.path forKey:@"path"];
	}
	
	if (self.contentType){
		[mDictionary setObject:self.contentType forKey:@"contentType"];
	}
	
	return mDictionary;
}

@end
