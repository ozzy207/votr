//
//  DataManager+Analytics.m
//  Votr
//
//  Created by Edward Kim on 1/7/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager+Analytics.h"

@implementation DataManager (Analytics)


+ (void)logEventSearchedTerm:(NSString*)searchTerm
{
	[FIRAnalytics logEventWithName:kFIREventSelectContent
						parameters:@{
									 kFIRParameterSearchTerm:searchTerm
									 }];
}


@end
