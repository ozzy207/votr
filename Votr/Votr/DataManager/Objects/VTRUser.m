//
//  VTRUser.m
//  Votr
//
//  Created by Edward Kim on 2/19/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "VTRUser.h"

@implementation VTRUser

- (NSMutableDictionary*)posts
{
	if (_posts == nil) {
		_posts = [NSMutableDictionary new];
	}
	return _posts;
}

- (NSMutableDictionary*)postsVoted
{
	if (_postsVoted == nil) {
		_postsVoted = [NSMutableDictionary new];
	}
	return _postsVoted;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString:@"photoURL"]) {
		_photoURL = [NSURL URLWithString:value];
		return;
	}
	[super setValue:value forKey:key];
}

- (NSMutableDictionary*)followers
{
	if (_followers == nil) {
		_followers = [NSMutableDictionary new];
	}
	return _followers;
}

- (NSMutableDictionary*)following
{
	if (_following == nil) {
		_following = [NSMutableDictionary new];
	}
	return _following;
}


- (NSMutableDictionary*)dictionaryRepresentation
{
	NSMutableDictionary *mDictionary = [super dictionaryRepresentation];
	
	if (self.posts) {
		[mDictionary setObject:self.posts forKey:@"posts"];
	}
	
	if (self.photoURL) {
		[mDictionary setObject:[self.photoURL absoluteString] forKey:@"photoURL"];
	}
	
	if (self.postsVoted){
		[mDictionary setObject:self.postsVoted forKey:@"postsVoted"];
	}
	
	if (self.topics) {
		[mDictionary setObject:self.topics forKey:@"topics"];
	}
	
	if (self.displayName){
		[mDictionary setObject:self.displayName forKey:@"displayName"];
	}
	
	if (self.followers) {
		[mDictionary setObject:self.followers forKey:@"followers"];
	}
	
	if (self.following) {
		[mDictionary setObject:self.following forKey:@"following"];
	}
	
	if (self.photoPath) {
		[mDictionary setObject:self.photoPath forKey:@"photoPath"];
	}
	return mDictionary;
}
@end
