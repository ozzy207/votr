//
//  ResultsTableVC.h
//  Votr
//
//  Created by tmaas510 on 23/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsTableVC : UITableViewController

@property (nonatomic, weak) PFObject *poll;
@property (nonatomic, assign) BOOL isLoaded;

@end
