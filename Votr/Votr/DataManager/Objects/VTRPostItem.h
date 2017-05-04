//
//  VTRPollItem.h
//  Votr
//
//  Created by Edward Kim on 1/19/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseDataObject.h"

@interface VTRPostItem : BaseDataObject
@property (strong, nonatomic) NSURL *url;
//Temp usage for passing image data... Too lazy to make a data object just for upload...
@property (strong, nonatomic) NSData *data;
//@property (strong, nonatomic) NSArray *voters;
@property (strong, nonatomic) NSString *path;
//@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *contentType;
@end
