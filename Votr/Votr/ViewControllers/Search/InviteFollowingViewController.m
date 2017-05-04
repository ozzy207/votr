//
//  InviteFollowingViewController.m
//  Votr
//
//  Created by Edward Kim on 3/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "InviteFollowingViewController.h"

@interface InviteFollowingViewController ()
@property (strong, nonatomic) NSArray *sectionTitles;
@end

@implementation InviteFollowingViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Invite" style:UIBarButtonItemStyleDone target:self action:@selector(inviteUsers:)];
	[self.navigationItem setRightBarButtonItem:rightItem];
	
	[self.tableView setSectionHeaderHeight:55];
	
	__weak typeof(self)weakSelf = self;
	self.sectionTitles = @[@"Invite",@"Following",@"People"];
	[self instantiate];
	[[[[DataManager sharedInstance] refDatabase] child:@"users"]  observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		if([snapshot.value isKindOfClass:[NSDictionary class]]){
			[weakSelf instantiate];
			NSMutableArray *following = [NSMutableArray new];
			NSMutableArray *allUsers = [NSMutableArray new];
			for (NSString *key in [snapshot.value allKeys]) {
				VTRUser *user = [VTRUser instanceFromDictionary:snapshot.value[key]];
				if ([user.followers objectForKey:[FIRAuth auth].currentUser.uid]) {
					[following addObject:user];
				}else if (![user.key isEqualToString:[FIRAuth auth].currentUser.uid]){
					[allUsers addObject:user];
				}
			}
			weakSelf.data[1] = following;
			weakSelf.data[2] = allUsers;
			weakSelf.filteredData = [@[[weakSelf.data[0] mutableCopy],[weakSelf.data[1] mutableCopy],[weakSelf.data[2] mutableCopy]]mutableCopy];
			[weakSelf.tableView reloadData];
		}else{
			[weakSelf instantiate];
			[weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.data.count)] withRowAnimation:UITableViewRowAnimationFade];
			[weakSelf.tableView reloadData];
		}
		
	}];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}



 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{

 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
//}
 

- (void)instantiate
{
	self.data = [@[[@[] mutableCopy],[@[] mutableCopy],[@[] mutableCopy]] mutableCopy];
	self.filteredData = [@[[@[] mutableCopy],[@[] mutableCopy],[@[] mutableCopy]] mutableCopy];
}

#pragma mark - Action
- (void)inviteUsers:(id)sender
{
	NSArray *userIDs = [self.data[0] valueForKey:@"key"];
	NSMutableDictionary *dict = [NSMutableDictionary new];
	if (self.inviteUsers) {
		for (NSString *uid in userIDs) {
			[dict setObject:@YES forKey:uid];
		}
		self.inviteUsers(dict);
		
		if (self.post) {
		
			[[[[[[DataManager sharedInstance] refDatabase] child:@"posts"] child:self.post.key] child:@"allowedUsers"] updateChildValues:dict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
					[self back:self];
			}];
		}
	}
	[self back:self];
}

//Override
- (void)tearDownObservers
{
	
}

- (void)setupPostSearch
{
	
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		//remove from section 0
		VTRUser *user = self.filteredData[indexPath.section][indexPath.row];
		
		if ([self.data[0] containsObject:user]){
			[self.data[0] removeObject:user];
		}
		
		[self.filteredData[0] removeObject:user];
		[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
	if (indexPath.section > 0) {
		//check if exists in section 0 if not add to section 0
		VTRUser *user = self.filteredData[indexPath.section][indexPath.row];
		if (![self.filteredData[0] containsObject:user]) {
			[self.data[0] insertObject:user atIndex:0];
			[self.filteredData[0] insertObject:user atIndex:0];
			[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		}

	}
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	NSMutableArray *following = [NSMutableArray new];
	NSMutableArray *people = [NSMutableArray new];
	//Filter following
	for (VTRUser *user in self.data[1]) {
		if (user.displayName.length>0 && searchText.length>0){
			if (!([user.displayName rangeOfString:searchText options:NSCaseInsensitiveSearch].location==NSNotFound)) {
				[following addObject:user];
			}
		}else{
			[following addObject:user];
		}
	}
	
	//Filter people
	for (VTRUser *user in self.data[2]) {
		if (user.displayName.length>0 && searchText.length>0){
			if (!([user.displayName rangeOfString:searchText options:NSCaseInsensitiveSearch].location==NSNotFound)) {
				[people addObject:user];
			}
		}else{
			[people addObject:user];
		}
	}
	
	self.filteredData = [@[[self.data[0] mutableCopy],following,people] mutableCopy];
	[self.tableView reloadData];
	
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

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"People"];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	VTRUser *user = self.filteredData[indexPath.section][indexPath.row];
	
	[cell.searchView.titleLabel setText:user.displayName];
	
	UIImage *placeholderImage = [UIImage imageNamed:@"default_avatar"];
	[cell.searchView.imageView sd_setImageWithURL:user.photoURL placeholderImage:placeholderImage];
//	__block typeof (NSIndexPath*)blkPath = indexPath;
//	__weak typeof(self) weakSelf = self;
//	[[[[[DataManager sharedInstance] refDatabase] child:@"users"] child:key] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
//		VTRUser *user = [VTRUser instanceFromDictionary:snapshot.value];
//		BaseTableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:blkPath];
//		[cell.searchView.titleLabel setText:user.displayName];
//		UIImage *placeholderImage = [UIImage imageNamed:@"default_avatar"];
//	 
//		// Load the image using SDWebImage
//		[cell.searchView.imageView sd_setImageWithURL:user.photoURL placeholderImage:placeholderImage];
//		[cell layoutIfNeeded];
//		[weakSelf.tableView beginUpdates];
//		[weakSelf.tableView endUpdates];
//	}];
	
	/*
		static NSString *identifier = @"People"; //added
	 VTRUser *user = [self.filteredData objectAtIndex:indexPath.row];
	 BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	 cell.searchView.titleLabel.text = user.displayName;
	 [cell.searchView.detailStackView setHidden:YES];
	 UIImage *placeholderImage = [UIImage imageNamed:@"default_avatar"];
	 
	 // Load the image using SDWebImage
	 [cell.searchView.imageView sd_setImageWithURL:user.photoURL placeholderImage:placeholderImage];
	 
	 
	 */
	return cell;
}

@end
