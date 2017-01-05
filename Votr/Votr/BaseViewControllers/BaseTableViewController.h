//
//  BaseTableViewController.h
//
//  Created by Edward Kim on 10/18/16.
//  Copyright © 2016 DedStop. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseTableViewCell.h"


@interface BaseTableViewController : BaseViewController <UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *data;

@end
