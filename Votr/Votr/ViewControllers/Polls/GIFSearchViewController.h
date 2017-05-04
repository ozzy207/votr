//
//  GIFSearchViewController.h
//  Votr
//
//  Created by Edward Kim on 1/21/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseSearchCollectionViewController.h"

@interface GIFSearchViewController : BaseSearchCollectionViewController
@property (nonatomic, copy) void (^contentCaptured)(NSURL *url);
@end
