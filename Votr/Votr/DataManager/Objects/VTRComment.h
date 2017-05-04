//
//  VTRComment.h
//  Votr
//
//  Created by Edward Kim on 2/25/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseDataObject.h"

@interface VTRComment : BaseDataObject
@property (strong, nonatomic) NSString *owner;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSArray *likes;
@end
