//
//  BaseQueryViewController.m
//  Votr
//
//  Created by Edward Kim on 2/28/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseQueryViewController.h"


@interface BaseQueryViewController ()<UISearchBarDelegate>

@end

@implementation BaseQueryViewController


#pragma mark - Life Cycle
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self.segmentedControl addTarget:self action:@selector(searchType:) forControlEvents:UIControlEventValueChanged];
	
	self.data = [NSMutableArray new];
	self.filteredData = [NSMutableArray new];
	//[self searchBar:self.searchBar textDidChange:@""];

	[self instantiate];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)instantiate
{
	switch (self.queryType) {
		case QUERY_TYPE_POST:{
			[self setupPostSearch];
			break;
		}
		case QUERY_TYPE_PEOPLE:
			[self setupPeopleSearch];
			break;
		case QUERY_TYPE_TAGS:
			[self setupTagSearch];
			break;
		case QUERY_TYPE_UNKOWN:
		default:
			[self setupPostSearch];
			break;
	}
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"Vote"]) {
		BaseVoteViewController *controller = segue.destinationViewController;
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		if ([[self.filteredData firstObject] isKindOfClass:[NSMutableArray class]]) {
			[controller setPost:self.filteredData[indexPath.section][indexPath.row]];
		}else{
			[controller setPost:self.filteredData[indexPath.row]];
		}
		
	}
	if ([segue.identifier isEqualToString:@"User"]) {
		UserViewController *controller = segue.destinationViewController;
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		VTRUser *obj;
		if ([[self.filteredData firstObject] isKindOfClass:[NSMutableArray class]]) {
			obj = self.filteredData[indexPath.section][indexPath.row];
		}else{
			obj = self.filteredData[indexPath.row];
		}
		[controller setUserKey:obj.key];
	}
	if ([segue.identifier isEqualToString:@"Tags"]) {
		BaseQueryViewController *controller = segue.destinationViewController;
		NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
		VTRTag *obj;
		if ([[self.filteredData firstObject] isKindOfClass:[NSMutableArray class]]) {
			obj = self.filteredData[indexPath.section][indexPath.row];
		}else{
			obj = self.filteredData[indexPath.row];
		}
		[controller setQueryChildString:[NSString stringWithFormat:@"tags/%@",obj.key]];
		[controller setQueryType:QUERY_TYPE_POST];
		[controller setTitle:obj.title];
	}
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
}

#pragma mark - UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self.view endEditing:YES];
}

#pragma mark - Query
- (void)searchType:(UISegmentedControl*)control
{
	[self tearDownObservers];
	self.data = [NSMutableArray new];
	self.filteredData = [NSMutableArray new];
	[self.tableView reloadData];
	switch (control.selectedSegmentIndex) {
		case 0:
			[self setupPostSearch];
			break;
		case 1:
			[self setupPeopleSearch];
			break;
		case 2:
			[self setupTagSearch];
			break;
		default:
			break;
	}
}

- (void)setupPostSearch
{
	//Query
	FIRDatabaseQuery *query;
	FIRDatabaseReference *ref;
	if (self.queryChildString) {
		query = [[[[[DataManager sharedInstance] refDatabase] child:@"posts"] queryOrderedByChild:self.queryChildString] queryEqualToValue:@YES];
	}else{
		ref = [[[DataManager sharedInstance] refDatabase] child:@"posts"];
	}
	
	//Update data with changes
	__weak typeof (self)weakSelf = self;
	FIRDatabaseHandle handle1 = [self.queryChildString?query:ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		VTRPost *newPost = [VTRPost instanceFromDictionary:snapshot.value];
		if (newPost.isPrivate) {
			if ([self hasAccessToPost:newPost]) {
				[weakSelf.data insertObject:newPost atIndex:0];
				//Check if value matches filter
				if(weakSelf.searchBar.text.length==0||([newPost.title rangeOfString:weakSelf.searchBar.text options:NSCaseInsensitiveSearch].location!=NSNotFound)){
					[weakSelf.filteredData insertObject:newPost atIndex:0];
					[weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
				}
			}
		}else{
			[weakSelf.data insertObject:newPost atIndex:0];
			//Check if value matches filter
			if(weakSelf.searchBar.text.length==0||([newPost.title rangeOfString:weakSelf.searchBar.text options:NSCaseInsensitiveSearch].location!=NSNotFound)){
				[weakSelf.filteredData insertObject:newPost atIndex:0];
				[weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
			}
		}
		

		
		//Filter data
	}];
	
	FIRDatabaseHandle handle2 = [self.queryChildString?query:ref observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
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
	
	FIRDatabaseHandle handle3 = [self.queryChildString?query:ref observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
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
	
	
	self.handles = [@[[VTRHandle handle:handle1 withRef:query?query.ref:ref],[VTRHandle handle:handle2 withRef:query?query.ref:ref],[VTRHandle handle:handle3 withRef:query?query.ref:ref]] mutableCopy];
}

- (void)setupPeopleSearch
{
	//Query
	FIRDatabaseQuery *query;
	FIRDatabaseReference *ref;
	if (self.queryChildString) {
		query = [[[[[DataManager sharedInstance] refDatabase] child:@"users"] queryOrderedByChild:self.queryChildString] queryEqualToValue:@YES];
	}else{
		ref = [[[DataManager sharedInstance] refDatabase] child:@"users"];
	}
	
	__weak typeof (self)weakSelf = self;
	//Update data with changes
	FIRDatabaseHandle handle1 = [self.queryChildString?query:ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		VTRUser *newPost = [VTRUser instanceFromDictionary:snapshot.value];
		[weakSelf.data insertObject:newPost atIndex:0];
		//Check if value matches filter
		if(weakSelf.searchBar.text.length==0||([newPost.title rangeOfString:weakSelf.searchBar.text options:NSCaseInsensitiveSearch].location!=NSNotFound)){
			[weakSelf.filteredData insertObject:newPost atIndex:0];
			[weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		}
		
		//Filter data
	}];
	
	FIRDatabaseHandle handle2 = [self.queryChildString?query:ref observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		for (NSInteger x = 0; x<weakSelf.data.count; x++) {
			VTRUser *post = weakSelf.data[x];
			if ([post.key isEqualToString:snapshot.key]) {
				[weakSelf.data removeObjectAtIndex:x];
				break;
			}
		}
		
		for (NSInteger x = 0; x<weakSelf.filteredData.count; x++) {
			VTRUser *post = weakSelf.filteredData[x];
			if ([post.key isEqualToString:snapshot.key]) {
				[weakSelf.filteredData removeObjectAtIndex:x];
				[weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:x inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
				break;
			}
		}
	}];
	
	FIRDatabaseHandle handle3 = [self.queryChildString?query:ref observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		for (NSInteger x = 0; x<weakSelf.data.count; x++) {
			VTRUser *post = weakSelf.data[x];
			if ([post.key isEqualToString:snapshot.key]) {
				weakSelf.data[x] = [VTRUser instanceFromDictionary:snapshot.value];
				break;
			}
		}
		
		for (NSInteger x = 0; x<weakSelf.filteredData.count; x++) {
			VTRUser *post = weakSelf.filteredData[x];
			if ([post.key isEqualToString:snapshot.key]) {
				weakSelf.filteredData[x] = [VTRUser instanceFromDictionary:snapshot.value];
				[weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:x inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
				break;
			}
		}
	}];
	
	
	self.handles = [@[[VTRHandle handle:handle1 withRef:query?query.ref:ref],[VTRHandle handle:handle2 withRef:query?query.ref:ref],[VTRHandle handle:handle3 withRef:query?query.ref:ref]] mutableCopy];
}

- (void)setupTagSearch
{

	//Query
	FIRDatabaseQuery *query;
	FIRDatabaseReference *ref;
	if (self.queryChildString) {
		query = [[[[[DataManager sharedInstance] refDatabase] child:@"tags"] queryOrderedByChild:self.queryChildString] queryEqualToValue:@YES];
	}else{
		ref = [[[DataManager sharedInstance] refDatabase] child:@"tags"];
	}
	
	__weak typeof (self)weakSelf = self;
	//Update data with changes
	FIRDatabaseHandle handle1 = [self.queryChildString?query:ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		VTRTag *newPost = [VTRTag instanceFromDictionary:snapshot.value];
		[weakSelf.data insertObject:newPost atIndex:0];
		//Check if value matches filter
		if(weakSelf.searchBar.text.length==0||([newPost.title rangeOfString:weakSelf.searchBar.text options:NSCaseInsensitiveSearch].location!=NSNotFound)){
			[weakSelf.filteredData insertObject:newPost atIndex:0];
			[weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		}
		
		//Filter data
	}];
	
	FIRDatabaseHandle handle2 = [self.queryChildString?query:ref observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		for (NSInteger x = 0; x<weakSelf.data.count; x++) {
			VTRTag *post = weakSelf.data[x];
			if ([post.key isEqualToString:snapshot.key]) {
				[weakSelf.data removeObjectAtIndex:x];
				break;
			}
		}
		
		for (NSInteger x = 0; x<weakSelf.filteredData.count; x++) {
			VTRTag *post = weakSelf.filteredData[x];
			if ([post.key isEqualToString:snapshot.key]) {
				[weakSelf.filteredData removeObjectAtIndex:x];
				[weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:x inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
				break;
			}
		}
	}];
	
	FIRDatabaseHandle handle3 = [self.queryChildString?query:ref observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		for (NSInteger x = 0; x<weakSelf.data.count; x++) {
			VTRTag *post = weakSelf.data[x];
			if ([post.key isEqualToString:snapshot.key]) {
				weakSelf.data[x] = [VTRTag instanceFromDictionary:snapshot.value];
				break;
			}
		}
		
		for (NSInteger x = 0; x<weakSelf.filteredData.count; x++) {
			VTRTag *post = weakSelf.filteredData[x];
			if ([post.key isEqualToString:snapshot.key]) {
				weakSelf.filteredData[x] = [VTRTag instanceFromDictionary:snapshot.value];
				[weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:x inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
				break;
			}
		}
	}];
	
	self.handles = [@[[VTRHandle handle:handle1 withRef:query?query.ref:ref],[VTRHandle handle:handle2 withRef:query?query.ref:ref],[VTRHandle handle:handle3 withRef:query?query.ref:ref]] mutableCopy];
}

#pragma mark - UISearchBar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	switch (self.segmentedControl.selectedSegmentIndex) {
		case 0:{
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
			break;
		}
		case 1:{
			NSMutableArray *marray = [NSMutableArray new];
			for (VTRUser *post in self.data) {
				if (post.displayName.length>0 && searchText.length>0){
					if (!([post.displayName rangeOfString:searchText options:NSCaseInsensitiveSearch].location==NSNotFound)) {
						[marray addObject:post];
					}
				}else{
					[marray addObject:post];
				}
			}
			self.filteredData = marray;
			[self.tableView reloadData];
			break;
		}
		case 2:{
			NSMutableArray *marray = [NSMutableArray new];
			for (VTRTag *post in self.data) {
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
			break;
		}
		default:
			break;
	}
}

#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.filteredData count];
}

- (UITableViewCell*)setupPostCell:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath
{
	static NSString *identifier = @"Posts"; //added
	VTRPost *post = [self.filteredData objectAtIndex:indexPath.row];
	BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	cell.searchView.titleLabel.text = post.title;
	[[[cell.searchView.detailStackView subviews] firstObject] setHidden:!post.isPrivate];
	//Timer
	[[[cell.searchView.detailStackView subviews] lastObject] setHidden:YES];
	cell.searchView.detailLabel2.text = [NSString stringWithFormat:@"%lu",[post.votes count]];
	cell.searchView.detailLabel3.text = [NSString stringWithFormat:@"%lu",[post.comments count]];;
	//C=blue,E=Gray,G=Green
	NSString *userKey = [FIRAuth auth].currentUser.uid;
	if ([userKey isEqualToString:post.owner]) {
		[cell.searchView.statusView setColorCode:@"C"];
	}else if ([post.votes objectForKey:userKey]){
		[cell.searchView.statusView setColorCode:@"E"];
	}else {
		[cell.searchView.statusView setColorCode:@"G"];
	}
	
	__block VTRPost* blkPost = post;
	__weak typeof(self)weakSelf = self;
	
	[[DataManager sharedInstance] getUser:post.owner completion:^(VTRUser *user) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[weakSelf.filteredData indexOfObject:blkPost] inSection:0];
		dispatch_async(dispatch_get_main_queue(), ^{
			BaseTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			cell.searchView.detailLabel1.text = user.displayName;
			UIImage *placeholderImage = [UIImage imageNamed:@"default_avatar"];
			
			// Load the image using SDWebImage
			[cell.searchView.imageView sd_setImageWithURL:user.photoURL placeholderImage:placeholderImage];
		});
	}];
	return cell;
}

- (UITableViewCell*)setupPeopleCell:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath
{
	static NSString *identifier = @"People"; //added
	VTRUser *user = [self.filteredData objectAtIndex:indexPath.row];
	BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	cell.searchView.titleLabel.text = user.displayName;
	[cell.searchView.detailStackView setHidden:YES];
	UIImage *placeholderImage = [UIImage imageNamed:@"default_avatar"];
	
	// Load the image using SDWebImage
	[cell.searchView.imageView sd_setImageWithURL:user.photoURL placeholderImage:placeholderImage];
	
	
	return cell;
}

- (UITableViewCell*)setupTagCell:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath
{
	static NSString *identifier = @"Tags"; //added
	VTRTag *tag = [self.filteredData objectAtIndex:indexPath.row];
	BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	cell.searchView.titleLabel.text = tag.title;
	cell.searchView.detailLabel1.text = [NSString stringWithFormat:@"%lu",(unsigned long)[tag.posts count]];
	cell.searchView.detailLabel2.text = tag.posts.count>0?@"polls":@"poll";
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.segmentedControl) {
		switch (self.segmentedControl.selectedSegmentIndex) {
			case 0:
				return [self setupPostCell:tableView indexPath:indexPath];
			case 1:
				return [self setupPeopleCell:tableView indexPath:indexPath];
			case 2:
				return [self setupTagCell:tableView indexPath:indexPath];
			default:
				break;
		}
	}else{
		switch (self.queryType) {
			case QUERY_TYPE_POST:
				return [self setupPostCell:tableView indexPath:indexPath];
				break;
			case QUERY_TYPE_PEOPLE:
				[self setupPeopleCell:tableView indexPath:indexPath];
				break;
			case QUERY_TYPE_TAGS:
				[self setupTagCell:tableView indexPath:indexPath];
				break;
			case QUERY_TYPE_UNKOWN:
			default:
				return [self setupPostCell:tableView indexPath:indexPath];
				break;
		}
	}

	return nil;
}

@end
