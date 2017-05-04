//
//  BaseDataObject.h
//  Votr
//
//  Created by Edward Kim on 1/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseDataObject : NSObject
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *key;
+ (instancetype)instanceFromDictionary:(NSDictionary*)dictionary;

- (NSString*)stringFromDate:(NSDate*)date;
- (NSDate*)dateFromString:(NSString*)dateString;
- (NSMutableDictionary*)dictionaryRepresentation;
@end
