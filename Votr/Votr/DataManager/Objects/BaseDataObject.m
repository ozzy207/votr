//
//  BaseDataObject.m
//  Votr
//
//  Created by Edward Kim on 1/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseDataObject.h"

@implementation BaseDataObject

+ (instancetype)instanceFromDictionary:(NSDictionary*)dictionary
{
	id instance = [[[self class] alloc] init];
	[instance setAttributesFromDictionary:dictionary];
	return instance;
}

- (void)setAttributesFromDictionary:(NSDictionary*)dictionary
{
	if (![dictionary isKindOfClass:[NSDictionary class]]){
		return;
	}
	[self setValuesForKeysWithDictionary:dictionary];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	[super setValue:value forKey:key];
}

- (NSString*)stringFromDate:(NSDate*)date
{
	NSDateFormatter *dateFormat = [NSDateFormatter new];
	[dateFormat setDateFormat: @"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
	return [dateFormat stringFromDate:date];
}

- (NSDate*)dateFromString:(NSString*)dateString
{
	NSDateFormatter *dateFormat = [NSDateFormatter new];
	[dateFormat setDateFormat: @"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
	return [dateFormat dateFromString:dateString];
}

- (NSMutableDictionary*)dictionaryRepresentation
{
	NSMutableDictionary *mDictionary = [NSMutableDictionary new];
	
	if (self.title){
		[mDictionary setObject:self.title forKey:@"title"];
	}
	
	if (self.key){
		[mDictionary setObject:self.key forKey:@"key"];
	}
	return mDictionary;
}

@end
