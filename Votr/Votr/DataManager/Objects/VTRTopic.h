//
//  VTRTopic.h
//  Votr
//
//  Created by Edward Kim on 1/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseDataObject.h"

@interface VTRTopic : BaseDataObject
@property (copy, nonatomic) NSString *key;
@property (copy, nonatomic) NSString *title;
+ (instancetype)instanceWithKey:(NSString*)key title:(NSString*)title;
@end
