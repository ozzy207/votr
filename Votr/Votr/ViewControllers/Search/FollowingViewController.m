//
//  FollowingViewController.m
//  Votr
//
//  Created by Edward Kim on 2/28/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "FollowingViewController.h"

@interface FollowingViewController ()
@property (strong, nonatomic) NSDictionary *following;
@property (strong, nonatomic) NSArray *sectionTitles;
@end

@implementation FollowingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.tableView setSectionHeaderHeight:55];
	
	self.sectionTitles = @[@"Private",@"Public"];
	__weak typeof(self)weakSelf = self;
	[self instantiate];
	[[[[[[DataManager sharedInstance] refDatabase] child:@"users"] child:[FIRAuth auth].currentUser.uid] child:@"following"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		if([snapshot.value isKindOfClass:[NSDictionary class]]){
			weakSelf.following = snapshot.value;
			[weakSelf instantiate];
			[weakSelf tearDownObservers];
			[weakSelf setupPostSearch];
		}else{
			weakSelf.following = [NSMutableDictionary new];
			[weakSelf instantiate];
			[weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, weakSelf.data.count)] withRowAnimation:UITableViewRowAnimationFade];
			[weakSelf tearDownObservers];
			[weakSelf setupPostSearch];
		}

	}];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)instantiate
{
	self.data = [@[[@[] mutableCopy],[@[] mutableCopy]] mutableCopy];
	self.filteredData = [@[[@[] mutableCopy],[@[] mutableCopy]] mutableCopy];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setupPostSearch
{
	//Query
	FIRDatabaseReference *ref = [[[DataManager sharedInstance] refDatabase] child:@"posts"];
	
	//Update data with changes
	__weak typeof (self)weakSelf = self;
	FIRDatabaseHandle handle1 = [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		VTRPost *newPost = [VTRPost instanceFromDictionary:snapshot.value];
		for (NSString *key in weakSelf.following) {
			if ([newPost.owner isEqualToString:key]) {
				if ([self hasAccessToPost:newPost]) {
					[weakSelf.data[0] insertObject:newPost atIndex:0];
				}else{
					[weakSelf.data[1] insertObject:newPost atIndex:0];
				}
				
				//Check if value matches filter
				if(weakSelf.searchBar.text.length==0||([newPost.title rangeOfString:weakSelf.searchBar.text options:NSCaseInsensitiveSearch].location!=NSNotFound)){
					
					if ([self hasAccessToPost:newPost]) {
						[weakSelf.filteredData[0] insertObject:newPost atIndex:0];
						[weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
					}else{
						[weakSelf.filteredData[1] insertObject:newPost atIndex:0];
						[weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
					}
					
				}
				break;
			}
		}

	}];
	
	FIRDatabaseHandle handle2 = [ref observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		for (NSInteger x = 0; x<weakSelf.data.count; x++) {
			for (NSInteger y = 0; y<weakSelf.data.count; y++) {
				VTRPost *post = weakSelf.data[x][y];
				if ([post.key isEqualToString:snapshot.key]) {
					[weakSelf.data[x] removeObjectAtIndex:y];
					break;
				}
			}
		}
		
		for (NSInteger x = 0; x<weakSelf.filteredData.count; x++) {
			for (NSInteger y = 0; y<weakSelf.filteredData.count; y++) {
				VTRPost *post = weakSelf.filteredData[x][y];
				if ([post.key isEqualToString:snapshot.key]) {
					[weakSelf.filteredData removeObjectAtIndex:x];
					[weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:y inSection:x]] withRowAnimation:UITableViewRowAnimationFade];
					break;
				}
			}
		}
	}];
	
	FIRDatabaseHandle handle3 = [ref observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		for (NSInteger x = 0; x<weakSelf.data.count; x++) {
			for (NSInteger y = 0; y<weakSelf.data.count; y++) {
				VTRPost *post = weakSelf.data[x][y];
				if ([post.key isEqualToString:snapshot.key]) {
					weakSelf.data[x][y] = [VTRPost instanceFromDictionary:snapshot.value];
					break;
				}
			}
		}
		for (NSInteger x = 0; x<weakSelf.filteredData.count; x++) {
			for (NSInteger y = 0; y<weakSelf.filteredData.count; y++) {
				VTRPost *post = weakSelf.data[x][y];
				if ([post.key isEqualToString:snapshot.key]) {
					weakSelf.filteredData[x] = [VTRPost instanceFromDictionary:snapshot.value];
					[weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:y inSection:x]] withRowAnimation:UITableViewRowAnimationFade];
					break;
				}
			}
		}
	}];
	
	
	self.handles = [@[[VTRHandle handle:handle1 withRef:ref],[VTRHandle handle:handle2 withRef:ref],[VTRHandle handle:handle3 withRef:ref]] mutableCopy];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	NSMutableArray *marray = [NSMutableArray new];
	for (NSInteger section = 0; section<self.data.count; section++) {
		for (NSInteger row = 0; row<self.data.count; row++) {
			VTRPost *post = self.data[section][row];
			if (post.title.length>0 && searchText.length>0){
				if (!([post.title rangeOfString:searchText options:NSCaseInsensitiveSearch].location==NSNotFound)) {
					[marray addObject:post];
				}
			}else{
				[marray addObject:post];
			}
		}
		
	}
	self.filteredData = marray;
	[self.tableView reloadData];
}


- (UITableViewCell*)setupPostCell:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath
{
	static NSString *identifier = @"Posts"; //added
	VTRPost *post = [self.filteredData[indexPath.section] objectAtIndex:indexPath.row];
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
		NSInteger row = 0;
		NSIndexPath *indexPath;
		for (NSInteger section = 0; section<weakSelf.filteredData.count; section++) {
			row = [weakSelf.filteredData[section] indexOfObject:blkPost];
			if (row != NSNotFound) {
				indexPath = [NSIndexPath indexPathForRow:row inSection:section];
				break;
			}
		}
		
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
	VTRUser *user = [self.filteredData[indexPath.section] objectAtIndex:indexPath.row];
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
	VTRTag *tag = [self.filteredData[indexPath.section] objectAtIndex:indexPath.row];
	BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	cell.searchView.titleLabel.text = tag.title;
	cell.searchView.detailLabel1.text = [NSString stringWithFormat:@"%lu",(unsigned long)[tag.posts count]];
	cell.searchView.detailLabel2.text = tag.posts.count>0?@"polls":@"poll";
	
	return cell;
}


#pragma mark - UITableView Datasource
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"headerView"];
	[cell.titleLabel setText:self.sectionTitles[section]];
	return cell.contentView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.filteredData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.filteredData[section] count];
}

@end
