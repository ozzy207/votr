//
//  DataManager+Analytics.h
//  Votr
//
//  Created by Edward Kim on 1/7/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager.h"

@interface DataManager (Analytics)

+ (void)logEventSearchedTerm:(NSString*)searchTerm;

@end
