//
//  BaseQueryViewController.h
//  Votr
//
//  Created by Edward Kim on 2/28/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseTableViewController.h"
#import "BRBaseSearchCellView.h"
#import "VTRPost.h"
#import "UIImageView+WebCache.h"
#import "DataManager+Posts.h"
#import "DataManager+Tags.h"
#import "DataManager+User.h"
#import "BRBaseSearchCellView.h"
#import "BaseVoteViewController.h"
#import "UserViewController.h"
#import "BRView.h"

typedef enum {
	QUERY_TYPE_UNKOWN,
	QUERY_TYPE_POST,
	QUERY_TYPE_PEOPLE,
	QUERY_TYPE_TAGS
} QUERY_TYPE;
@interface BaseQueryViewController : BaseTableViewController
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) NSMutableArray *filteredData;
@property (strong, nonatomic) NSString *queryChildString;
@property (nonatomic) QUERY_TYPE queryType;

- (void)instantiate;

- (void)searchType:(UISegmentedControl*)control;
- (void)setupPostSearch;
- (void)setupPeopleSearch;
- (void)setupTagSearch;

- (UITableViewCell*)setupPostCell:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;
- (UITableViewCell*)setupPeopleCell:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;
- (UITableViewCell*)setupTagCell:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;

@end
