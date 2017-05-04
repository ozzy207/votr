//
//  UserViewController.m
//  Votr
//
//  Created by Edward Kim on 2/26/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "UserViewController.h"
#import "UIImageView+WebCache.h"
#import "BRImageView.h"
#import "BRButton.h"
#import "BRLabel.h"
#import "VTRPost.h"
#import "BRPostSearchCellView.h"
#import "BRView.h"
#import "BaseVoteViewController.h"

@interface UserViewController ()
@property (strong, nonatomic) IBOutlet BRLabel *titleLabel;
@property (strong, nonatomic) IBOutlet BRImageView *detailImageView1;
@property (strong, nonatomic) IBOutlet BRButton *detailLabel1;
@property (strong, nonatomic) IBOutlet BRLabel *detailLabel2;
@property (strong, nonatomic) IBOutlet BRLabel *detailLabel3;
@property (strong, nonatomic) IBOutlet BRLabel *detailLabel4;
@property (strong, nonatomic) VTRUser *user;
@property (strong, nonatomic) IBOutlet BRButton *followButton;
@end

@implementation UserViewController

#pragma mark - Life Cycle
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	if (self.userKey) {
		[self tearDownObservers];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)viewDidLoad
 {
    [super viewDidLoad];

	[self initialize];
	self.data = [NSMutableArray new];
	 
	 __weak typeof(self) weakSelf = self;
	[[[[[DataManager sharedInstance] refDatabase] child:@"users"] child:self.userKey?self.userKey:[FIRAuth auth].currentUser.uid] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		weakSelf.user = [VTRUser instanceFromDictionary:snapshot.value];
		
		if ([weakSelf.user.key isEqualToString:[FIRAuth auth].currentUser.uid]) {
			[weakSelf.followButton setHidden:YES];
			[weakSelf.navigationItem.rightBarButtonItem setEnabled:YES];
		}else{
			[weakSelf.followButton setHidden:NO];
			[weakSelf.navigationItem.rightBarButtonItem setEnabled:NO];
		}
		
		if (weakSelf.user.followers[[FIRAuth auth].currentUser.uid]) {
			[weakSelf.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
		}else{
			[weakSelf.followButton setTitle:@"Follow" forState:UIControlStateNormal];
		}
		//[self.navigationController.navigationBar.topItem setTitle:self.user.displayName];
		[weakSelf.titleLabel setText:weakSelf.user.displayName];
		
		UIImage *placeholderImage = [UIImage imageNamed:@"default_avatar"];
		// Load the image using SDWebImage
		[weakSelf.detailImageView1	sd_setImageWithURL:weakSelf.user.photoURL placeholderImage:placeholderImage];
		
		[weakSelf.detailLabel2 setText:[NSString stringWithFormat:@"%lu",[weakSelf.user.posts count]]];
		[weakSelf.detailLabel3 setText:[NSString stringWithFormat:@"%lu",[weakSelf.user.following count]]];
		[weakSelf.detailLabel4 setText:[NSString stringWithFormat:@"%lu",[weakSelf.user.followers count]]];
		[weakSelf.tableView reloadData];
	}];
	
	[self setupPostQuery];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialize
{

	[self.titleLabel setText:@""];
	[self.followButton setHidden:YES];
	
	[self.navigationItem.rightBarButtonItem setEnabled:NO];
	UIImage *placeholderImage = [UIImage imageNamed:@"default_avatar"];
	// Load the image using SDWebImage
	[self.detailImageView1 setImage:placeholderImage];
	
	[self.detailLabel2 setText:@""];
	[self.detailLabel3 setText:@""];
	[self.detailLabel4 setText:@""];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"Vote"]) {
		BaseVoteViewController *controller = segue.destinationViewController;
		NSInteger index = [[self.tableView indexPathForCell:sender] row];
		[controller setPost:self.data[index]];
	}
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
}


- (IBAction)viewPolls:(id)sender
{
	
}

- (IBAction)viewFollowing:(id)sender
{
	
}

- (IBAction)viewFollowers:(id)sender
{
	
}

- (IBAction)followUser:(id)sender
{
	//If posts user is followed by current user remove else add
	if (self.user.followers[[FIRAuth auth].currentUser.uid]) {
		[self.user.followers removeObjectForKey:[FIRAuth auth].currentUser.uid];
		[self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
	}else{
		[self.user.followers setValue:@YES forKey:[FIRAuth auth].currentUser.uid];
		[self.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
	}
	
	[[[[[[DataManager sharedInstance] refDatabase] child:@"users"] child:self.user.key] child:@"followers"] setValue:self.user.followers];
	
	__weak typeof(self) weakself = self;
	[[[[[[DataManager sharedInstance] refDatabase] child:@"users"] child:[FIRAuth auth].currentUser.uid] child:@"following"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		NSMutableDictionary *following;
		if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
			following = [snapshot.value mutableCopy];
		}else{
			following = [NSMutableDictionary new];
		}
		if(weakself.user.followers[[FIRAuth auth].currentUser.uid]){
			[following setValue:[weakself.user.posts count]>0?weakself.user.posts:@YES forKey:weakself.user.key];
		}else{
			[following removeObjectForKey:weakself.user.key];
		}
		[[[[[[DataManager sharedInstance] refDatabase] child:@"users"] child:[FIRAuth auth].currentUser.uid] child:@"following"] setValue:following];
		
	}];
}


- (void)setupPostQuery
{
	FIRDatabaseQuery *query = [[[[[DataManager sharedInstance] refDatabase] child:@"posts"] queryOrderedByChild:@"owner"] queryEqualToValue:self.userKey?self.userKey:[FIRAuth auth].currentUser.uid];
	
	__weak typeof(self)weakSelf = self;
	FIRDatabaseHandle handle1 = [query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		VTRPost *newPost = [VTRPost instanceFromDictionary:snapshot.value];
		[weakSelf.data insertObject:newPost atIndex:0];
		//Check if value matches filter
		[weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		
		//Filter data
	}];
	
	FIRDatabaseHandle handle2 = [query observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		for (NSInteger x = 0; x<weakSelf.data.count; x++) {
			VTRPost *post = weakSelf.data[x];
			if ([post.key isEqualToString:snapshot.key]) {
				[weakSelf.data removeObjectAtIndex:x];
				[weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:x inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
				break;
			}
		}

	}];
	
	FIRDatabaseHandle handle3 = [query observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		for (NSInteger x = 0; x<self.data.count; x++) {
			VTRPost *post = self.data[x];
			if ([post.key isEqualToString:snapshot.key]) {
				self.data[x] = [VTRPost instanceFromDictionary:snapshot.value];
				[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:x inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
				break;
			}
		}
	}];
	
	self.handles = [@[[VTRHandle handle:handle1 withRef:query.ref],[VTRHandle handle:handle2 withRef:query.ref],[VTRHandle handle:handle3 withRef:query.ref]] mutableCopy];
}

#pragma mark - UITableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.data count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *identifier = @"default"; //added
	VTRPost *post = [self.data objectAtIndex:indexPath.row];
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
	
	UIImage *placeholderImage = [UIImage imageNamed:@"default_avatar"];
	
	// Load the image using SDWebImage
	[cell.searchView.imageView sd_setImageWithURL:self.user.photoURL placeholderImage:placeholderImage];
	cell.searchView.detailLabel1.text = self.user.displayName;
	return cell;
}

@end
