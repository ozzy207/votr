//
//  BaseDataObject.h
//  Votr
//
//  Created by Edward Kim on 1/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseDataObject : NSObject
+ (instancetype)instanceFromDictionary:(NSDictionary*)dictionary;

- (NSString*)stringFromDate:(NSDate*)date;
- (NSDate*)dateFromString:(NSString*)dateString;
- (NSDictionary*)dictionaryRepresentation;
@end
