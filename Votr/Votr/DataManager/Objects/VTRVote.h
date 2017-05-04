//
//  BTRVote.h
//  Votr
//
//  Created by Edward Kim on 2/25/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseDataObject.h"

@interface VTRVote : BaseDataObject
@property (strong, nonatomic) NSString *owner;
@property (strong, nonatomic) NSNumber *selectedIndex;
@end
