//
//  VTRTopic.m
//  Votr
//
//  Created by Edward Kim on 1/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "VTRTopic.h"

@implementation VTRTopic

+ (instancetype)instanceWithKey:(NSString*)key title:(NSString*)title
{
	VTRTopic *topic = [VTRTopic new];
	[topic setKey:key];
	[topic setTitle:title];
	return topic;
}


@end
