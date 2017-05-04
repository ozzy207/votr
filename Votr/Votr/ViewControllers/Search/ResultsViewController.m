//
//  ResultsViewController.m
//  Votr
//
//  Created by Edward Kim on 2/28/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "ResultsViewController.h"


@interface ResultsViewController ()

@end

@implementation ResultsViewController

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)instantiate
{
	[self setupQuery:0];
}

- (void)searchType:(UISegmentedControl*)control
{
	[self tearDownObservers];
	self.data = [NSMutableArray new];
	self.filteredData = [NSMutableArray new];
	[self.tableView reloadData];
	[self setupQuery:control.selectedSegmentIndex];
}

- (void)setupQuery:(NSInteger)type
{
	FIRDatabaseQuery *query;
	switch (type) {
		case 0:{
			query = [[[[[DataManager sharedInstance] refDatabase] child:@"posts"] queryOrderedByChild:@"owner"] queryEqualToValue:[FIRAuth auth].currentUser.uid];
			break;
			}
		case 1:{
			query = [[[[[DataManager sharedInstance] refDatabase] child:@"posts"] queryOrderedByChild:[NSString stringWithFormat:@"votes/%@",[FIRAuth auth].currentUser.uid]] queryStartingAtValue:@0];
			}
			break;
		default:{
			query = [[[[[DataManager sharedInstance] refDatabase] child:@"posts"] queryOrderedByChild:@"owner"] queryEqualToValue:[FIRAuth auth].currentUser.uid];
			break;
			}
	}

	__weak typeof(self)weakSelf = self;
	FIRDatabaseHandle handle1 = [query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		VTRPost *newPost = [VTRPost instanceFromDictionary:snapshot.value];
		[weakSelf.data insertObject:newPost atIndex:0];
		//Check if value matches filter
		if(weakSelf.searchBar.text.length==0||([newPost.title rangeOfString:weakSelf.searchBar.text options:NSCaseInsensitiveSearch].location!=NSNotFound)){
			[weakSelf.filteredData insertObject:newPost atIndex:0];
			[weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		}
		//Filter data
	}];
	
	FIRDatabaseHandle handle2 = [query observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		for (NSInteger x = 0; x<weakSelf.data.count; x++) {
			VTRPost *post = weakSelf.data[x];
			if ([post.key isEqualToString:snapshot.key]) {
				[weakSelf.data removeObjectAtIndex:x];
				break;
			}
		}
		
		for (NSInteger x = 0; x<weakSelf.filteredData.count; x++) {
			VTRPost *post = self.filteredData[x];
			if ([post.key isEqualToString:snapshot.key]) {
				[weakSelf.filteredData removeObjectAtIndex:x];
				[weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:x inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
				break;
			}
		}
		
	}];
	
	FIRDatabaseHandle handle3 = [query observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		for (NSInteger x = 0; x<weakSelf.data.count; x++) {
			VTRPost *post = weakSelf.data[x];
			if ([post.key isEqualToString:snapshot.key]) {
				weakSelf.data[x] = [VTRPost instanceFromDictionary:snapshot.value];
				break;
			}
		}
		
		for (NSInteger x = 0; x<weakSelf.filteredData.count; x++) {
			VTRPost *post = weakSelf.filteredData[x];
			if ([post.key isEqualToString:snapshot.key]) {
				weakSelf.filteredData[x] = [VTRPost instanceFromDictionary:snapshot.value];
				[weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:x inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
				break;
			}
		}
	}];
	
	self.handles = [@[[VTRHandle handle:handle1 withRef:query.ref],[VTRHandle handle:handle2 withRef:query.ref],[VTRHandle handle:handle3 withRef:query.ref]] mutableCopy];
}

#pragma mark - UISearchBar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	NSMutableArray *marray = [NSMutableArray new];
	for (VTRPost *post in self.data) {
		if (post.title.length>0 && searchText.length>0){
			if (!([post.title rangeOfString:searchText options:NSCaseInsensitiveSearch].location==NSNotFound)) {
				[marray addObject:post];
			}
		}else{
			[marray addObject:post];
		}
	}
	self.filteredData = marray;
	[self.tableView reloadData];
}

#pragma mark - UITableView Datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self setupPostCell:tableView indexPath:indexPath];;
}
@end
