//
//  BaseVoteViewController.m
//  Votr
//
//  Created by Edward Kim on 2/22/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseVoteViewController.h"
#import "UIImageView+WebCache.h"
#import "DataManager+Comments.h"
#import "DataManager+Posts.h"
#import "DataManager+User.h"
#import "DataManager+GIF.h"

#import "BRCommentCellView.h"
#import "BRButton.h"
#import "BRLabel.h"

#import "VTRPostItem.h"
#import "VTRComment.h"
#import "VTRPost.h"
#import "VTRVote.h"
#import "VTRHandle.h"

#import "BRFloatTextView.h"	
#import "BRVoteProgressView.h"
#import <AVFoundation/AVFoundation.h>
#import "FLAnimatedImage.h"

@interface BaseVoteViewController ()
@property (strong, nonatomic) IBOutlet UIStackView *voteStack;
@property (strong, nonatomic) IBOutlet UIView *commentButtonView;
@property (strong, nonatomic) IBOutlet BRButton *addCommentButton;
@property (strong, nonatomic) BRFloatTextView *floatView;
@property (strong, nonatomic) IBOutlet BRVoteProgressView *progressView1;
@property (strong, nonatomic) IBOutlet BRVoteProgressView *progressView2;
@property (strong, nonatomic) BaseTableViewCell *headerCell;
@end

@implementation BaseVoteViewController

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
	[[SDImageCache sharedImageCache] cleanDisk];
}


#pragma mark - Life Cycle
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (self.post && self.handles.count == 0) {
		[self setupObservers];
	}

}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self tearDownObservers];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
											   
	[self clearContent];
	
	self.data = [NSMutableArray new];
	
	
	if (self.post) {
		[self setupPostData];
	}else{
		__weak typeof(self) weakSelf = self;
		UIBarButtonItem	 *donebtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
		[self.navigationItem setLeftBarButtonItem:donebtn];
		[[[[[DataManager sharedInstance] refDatabase] child:@"posts"] child:self.postID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
			weakSelf.post = [VTRPost instanceFromDictionary:snapshot.value];
			[weakSelf clearContent];
			[self setupPostData];
		}];
	}
	
    // Do any additional setup after loading the view.
}

- (void)setupPostData
{
	[self setupObservers];
	[self.titleLabel setText:self.post.title];
	
	if ([self.post.owner isEqualToString:[DataManager sharedInstance].user.key]){
		[self.voteStack setHidden:YES];
		//[self.commentButtonView setHidden:NO];
	}else{
		[self.navigationItem setRightBarButtonItem:nil];
		if ([[[DataManager sharedInstance] user] postsVoted][self.post.key]) {
			[self.voteStack setHidden:YES];
		}
	}
	
	if ([self.post.votes valueForKey:[DataManager sharedInstance].user.key]){
		[self.commentButtonView setHidden:NO];
		[self.progressView1 setHidden:NO];
		[self.progressView2 setHidden:NO];
	}
	
	[self updateProgressViews];
	
	__weak typeof(self) weakSelf = self;
	
	[[[[[DataManager sharedInstance] refDatabase] child:@"users"] child:self.post.owner] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		VTRUser *user = [VTRUser instanceFromDictionary:snapshot.value];
		[weakSelf.detailLabel1 setText:user.displayName];
		UIImage *placeholderImage = [UIImage imageNamed:@"default_avatar"];
		
		[weakSelf.detailImageView1 sd_setImageWithURL:user.photoURL placeholderImage:placeholderImage];
		dispatch_async(dispatch_get_main_queue(), ^(void){
			[weakSelf sizeHeaderToFit];
		});
		if ([weakSelf.post.owner isEqualToString:[DataManager sharedInstance].user.key]){
			[weakSelf.commentButtonView setHidden:NO];
			[weakSelf.progressView1 setHidden:NO];
			[weakSelf.progressView2 setHidden:NO];
		}
	}];
	
	VTRPostItem *postItem1 = [self.post.items firstObject];
	VTRPostItem *postItem2 = [self.post.items lastObject];
	
	[self.detailLabel2 setText:postItem1.title];
	[self.detailLabel3 setText:postItem2.title];
	
	if ([postItem1.contentType isEqualToString:@"video/quicktime"]) {
		[self getVideo:postItem1 index:0];
	}else{
		self.detailImageView2.layer.sublayers = nil;
		[self.detailImageView2 setAnimationImages:nil];
		if ([[[postItem1 url] absoluteString] containsString:@"giphy"]) {
			//[FLAnimatedImage ];
			[[DataManager sharedInstance] loadGIF:postItem1.url onCompletion:^(NSData *data, NSError *error) {
				FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
				[self.detailImageView2 setAnimatedImage:image];
			}];
			
		}else{
			[self.detailImageView2 sd_setImageWithURL:postItem1.url placeholderImage:nil];
		}
		
	}
	
	
	if ([postItem2.contentType isEqualToString:@"video/quicktime"]) {
		[self getVideo:postItem2 index:1];
	}else{
		self.detailImageView3.layer.sublayers = nil;
		[self.detailImageView3 setAnimationImages:nil];
		//[self.detailImageView3 sd_setImageWithURL:postItem2.url placeholderImage:nil];
		if ([[[postItem2 url] absoluteString] containsString:@"giphy"]) {
			[[DataManager sharedInstance] loadGIF:postItem2.url onCompletion:^(NSData *data, NSError *error) {
				FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
				[self.detailImageView3 setAnimatedImage:image];
			}];
		}else{
			[self.detailImageView3 sd_setImageWithURL:postItem2.url placeholderImage:nil];
		}
	}

}

- (void)clearContent
{
	[self.titleLabel setText:@""];
	
	[self.tableView.tableHeaderView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 404)];
	[self.tableView setSectionHeaderHeight:50];
	
	[self.detailLabel1 setText:@""];
	[self.detailLabel2 setText:@""];
	[self.detailLabel3 setText:@""];
	
	[self.progressView1 setPercentage:0];
	[self.progressView2 setPercentage:0];
	[self.progressView1.detailLabel setText:@""];
	[self.progressView2.detailLabel setText:@""];
	[self.progressView1 setHidden:YES];
	[self.progressView2 setHidden:YES];
	
	[self.commentButtonView	setHidden:YES];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupObservers
{
	__weak typeof(self) weakSelf = self;
	
	FIRDatabaseReference *ref = [[[[[DataManager sharedInstance]refDatabase]child:@"posts"] child:self.post.key] child:@"comments"];
	//Comments
	FIRDatabaseHandle handle1 = [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		VTRComment *obj = [VTRComment instanceFromDictionary:snapshot.value];
		[weakSelf.data insertObject:obj atIndex:0];
		//Check if value matches filter
		[weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
		[weakSelf.headerCell.titleLabel setText:[NSString stringWithFormat:@"%lu Comments",(unsigned long)[self.data count]]];
		//[self addComment:self];
	}];
	
	FIRDatabaseHandle handle2 = [ref observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		VTRComment *obj = [VTRComment instanceFromDictionary:snapshot.value];
		
		for (NSInteger i = 0; i<weakSelf.data.count; i++) {
			VTRComment *temp = weakSelf.data[i];
			if ([temp.key isEqualToString:snapshot.key]) {
				weakSelf.data[i] = obj;
				[weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
				[weakSelf.headerCell.titleLabel setText:[NSString stringWithFormat:@"%lu Comments",(unsigned long)[weakSelf.data count]]];
				break;
			}
		}
	}];
	
	FIRDatabaseHandle handle3 = [ref observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		VTRComment *obj = [VTRComment instanceFromDictionary:snapshot.value];
		for (NSInteger i = 0; i<weakSelf.data.count; i++) {
			VTRComment *temp = weakSelf.data[i];
			if ([temp.key isEqualToString:obj.key]) {
				[weakSelf.data removeObjectAtIndex:i];
				[weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
				[weakSelf.headerCell.titleLabel setText:[NSString stringWithFormat:@"%lu Comments",(unsigned long)[weakSelf.data count]]];
				break;
			}
		}
	}];
	
	//Votes
	FIRDatabaseReference *ref2 = [[[[[DataManager sharedInstance]refDatabase]child:@"posts"] child:self.post.key] child:@"votes"];
	FIRDatabaseHandle handle4 = [ref2 observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		NSMutableDictionary *temp = [NSMutableDictionary new];
		if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
			for (NSString *key in [snapshot.value allKeys]) {
				[temp setObject:[VTRVote instanceFromDictionary:snapshot.value[key]] forKey:key];
			}
			[weakSelf.post setVotes:temp];
			//Update votes
			[weakSelf updateProgressViews];
		}
		
	}];
	[self.handles addObject:[VTRHandle handle:handle4 withRef:ref2]];
	[self.handles addObjectsFromArray:@[[VTRHandle handle:handle1 withRef:ref],[VTRHandle handle:handle2 withRef:ref],[VTRHandle handle:handle3 withRef:ref]]];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)getVideo:(VTRPostItem*)postItem index:(NSInteger)index
{

	__weak typeof(UIImageView*)weakImageView;

	switch (index) {
		case 0:
			weakImageView = self.detailImageView2;
			break;
		case 1:
			weakImageView = self.detailImageView3;
			break;
			
		default:
			break;
	}

	
	FIRStorageReference *ref = [[[[DataManager sharedInstance] refStorage] storage] referenceForURL:[postItem.url absoluteString]];
	NSURL *outputURL = [[[self applicationDocumentsDirectory] URLByAppendingPathComponent:@(index).stringValue] URLByAppendingPathExtension:@"mov"];
	[ref writeToFile:outputURL completion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
		weakImageView.layer.sublayers = nil;
		[weakImageView setAnimationImages:nil];
		
		AVPlayer *player = [AVPlayer playerWithURL:URL]; //
		player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
		
		AVPlayerLayer *layer = [AVPlayerLayer layer];
		
		[layer setPlayer:player];
		[layer setFrame:weakImageView.bounds];
		[layer setBackgroundColor:[UIColor clearColor].CGColor];
		[layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
		
		[weakImageView.layer addSublayer:layer];
		
		[player play];
	}];
}

- (void)updateProgressViews
{
	if (self.post.votes) {
		double total = [self.post.votes count];
		NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF == 0"];
		NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"SELF == 1"];
		
		NSArray *array1 = [[self.post.votes allValues] filteredArrayUsingPredicate:predicate1];
		NSArray *array2 = [[self.post.votes allValues] filteredArrayUsingPredicate:predicate2];

		double percentage1 = (double)[array1 count]/total;
		double percentage2 = (double)[array2 count]/total;
		[self.progressView1 changePercentage:percentage1];
		[self.progressView2 changePercentage:percentage2];
		
		if (percentage1>percentage2) {
			[self.progressView1 setColorCode:@"G"];
			[self.progressView2 setColorCode:@"K"];
		}else if (percentage2>percentage1){
			[self.progressView1 setColorCode:@"K"];
			[self.progressView2 setColorCode:@"G"];
		}else{
			[self.progressView1 setColorCode:@"K"];
			[self.progressView2 setColorCode:@"K"];
		}
	}
}

#pragma mark - Action
- (IBAction)delete:(id)sender
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Poll?" message:nil preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *action1 = [UIAlertAction	actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		[[DataManager sharedInstance] deletePost:self.post completion:^(NSError *error, FIRDatabaseReference *ref) {
			if (error) {
		// show error
			}else{
//				[[[[DataManager sharedInstance] refStorage] child:self.item1.path] deleteWithCompletion:^(NSError * _Nullable error) {
//					NSLog(@"%@",error);
//				}];
//				[[[[DataManager sharedInstance] refStorage] child:self.item2.path] deleteWithCompletion:^(NSError * _Nullable error) {
//					NSLog(@"%@",error);
//				}];
				[self.navigationController popViewControllerAnimated:YES];
			}
		}];
	}];
	
	UIAlertAction *action2 = [UIAlertAction	actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		
	}];
	
	[alert addAction:action1];
	[alert addAction:action2];
	
	[self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)vote:(UIButton*)sender
{
	[self.button1 setEnabled:NO];
	[self.button2 setEnabled:NO];
	
	__weak typeof (self) weakSelf = self;
	[[DataManager sharedInstance] votePostKey:self.post.key postItemIndex:sender.tag completion:^(FIRDataSnapshot * _Nullable snapshot) {
		NSDictionary *dict = snapshot.value;
		VTRPost *post = [VTRPost instanceFromDictionary:dict];
		weakSelf.post = post;
		[weakSelf.commentButtonView setHidden:NO];
		[weakSelf.progressView1 setHidden:NO];
		[weakSelf.progressView2 setHidden:NO];
		if([[[DataManager sharedInstance] user] postsVoted] [post.key]){
			[sender setEnabled:YES];
			[sender setTitle:@"Unvote" forState:UIControlStateNormal];
			[weakSelf.voteStack setHidden:YES];
			[weakSelf sizeHeaderToFit];
			
		}else{
			[weakSelf.button1 setEnabled:YES];
			[weakSelf.button2 setEnabled:YES];
			[weakSelf.commentButtonView setHidden:YES];
			[weakSelf.button1 setTitle:@"Choose" forState:UIControlStateNormal];
			[weakSelf.button2 setTitle:@"Choose" forState:UIControlStateNormal];
		}
		[weakSelf updateProgressViews];
	}];
}

- (IBAction)addComment:(UIButton*)sender
{
	if	(sender.tag== 0){
		sender.tag = 1;
		self.floatView = [[BRFloatTextView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-self.tabBarController.tabBar.frame.size.height-45,self.view.frame.size.width, 45)];
		//[self.floatView.textField1 setAutocorrectionType:UITextAutocorrectionTypeNo];
		[self.view addSubview:self.floatView];
		[self.floatView.button1 addTarget:self action:@selector(submitComment:) forControlEvents:UIControlEventTouchUpInside];
		[self.floatView.textField1 addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
		[self.floatView.button1 setEnabled:NO];
		[self.floatView.textField1 becomeFirstResponder];
		[sender setTitle:@"Cancel Add Comment" forState:UIControlStateNormal];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	}else{
		sender.tag = 0;
		[sender setTitle:@"Add Comment" forState:UIControlStateNormal];
		[self.floatView.textField1 resignFirstResponder];
		[self.floatView removeFromSuperview];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
	}
}

- (void)submitComment:(id)sender
{
	NSMutableDictionary *mdict = [self.post.comments mutableCopy];
	
	if (mdict == nil) {
		mdict = [NSMutableDictionary new];
	}
	
	VTRComment *comment = [VTRComment new];
	[comment setOwner:[DataManager sharedInstance].user.key];
	[comment setMessage:self.floatView.textField1.text];
	
	NSString *key = [[[[DataManager sharedInstance] refDatabase] childByAutoId] key];
	[mdict setValue:comment forKey:key];
	[comment setKey:key];
	//self.post.comments = mdict;
	
	[[[[[[DataManager sharedInstance] refDatabase] child:@"posts"] child:self.post.key] child:@"comments"] updateChildValues:@{key:[comment dictionaryRepresentation]}];
	
	[self.floatView.textField1 resignFirstResponder];
	[self.floatView removeFromSuperview];
	[self.commentButtonView setHidden:NO];
	[self.addCommentButton setTitle:@"Add Comment" forState:UIControlStateNormal];
	[self.addCommentButton setTag:0];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (IBAction)likeComment:(UIButton*)sender
{
	CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
	VTRComment *comment = self.data[indexPath.row];
	
	NSMutableArray *marray = [comment.likes mutableCopy];
	if (marray == nil) {
		marray = [NSMutableArray new];
	}
	
	NSString *userKey = [DataManager sharedInstance].user.key;
	if ([marray containsObject:userKey]) {
		[marray removeObject:userKey];
	}else{
		[marray addObject:userKey];
	}
	
	[comment setLikes:marray];
	
	//[self.post.comments setValue:comment forKey:comment.key];
	
	[[[[[[DataManager sharedInstance] refDatabase] child:@"posts"]child:self.post.key] child:@"comments"] updateChildValues:@{comment.key:[comment dictionaryRepresentation]}];
}

#pragma mark - Player Notification
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
	AVPlayerItem *p = [notification object];
	[p seekToTime:kCMTimeZero];
}

#pragma mark - UITextField
- (void)textFieldValueChanged:(UITextField*)textField
{
	[self.floatView.button1 setEnabled:textField.text.length>0];
}

#pragma mark - Keyboard Notifications
- (void)keyboardFrameChange:(NSNotification*)notification
{
	CGRect frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGFloat offset = self.view.frame.size.height-frame.size.height-self.floatView.frame.size.height;
	[self.floatView setFrame:CGRectMake(self.floatView.view.frame.origin.x, offset, self.floatView.frame.size.width, self.floatView.frame.size.height)];
//	[self.tableView setContentInset:UIEdgeInsetsMake(0, 0, frame.size.height+self.floatView.frame.size.height, 0)];
	//let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
	//textInputBar.frame.origin.y = frame.origin.y
}

- (void)keyboardDidShow:(NSNotification*)notification
{
	CGRect frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGFloat offset = self.view.frame.size.height-frame.size.height-self.floatView.frame.size.height;
	[self.floatView setFrame:CGRectMake(self.floatView.view.frame.origin.x, offset, self.floatView.frame.size.width, self.floatView.frame.size.height)];
	[self.tableView setContentInset:UIEdgeInsetsMake(0, 0, frame.size.height+self.floatView.frame.size.height, 0)];
	
	if (self.data.count>0){
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
}

- (void)keyboardDidHide:(NSNotification*)notification
{
	CGRect frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGFloat offset = self.view.frame.size.height-frame.size.height-self.floatView.frame.size.height;
	[self.floatView setFrame:CGRectMake(self.floatView.view.frame.origin.x, offset, self.floatView.frame.size.width, self.floatView.frame.size.height)];
	[self.tableView setContentInset:UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0)];
	if (self.data.count>0){
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
}

#pragma mark - UITableView Datasource
//- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//	return [NSString stringWithFormat:@"%lu Comments",[self.data count]];
//}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	self.headerCell = [tableView dequeueReusableCellWithIdentifier:@"headerView"];
	[self.headerCell.titleLabel setText:[NSString stringWithFormat:@"%lu %@",(unsigned long)[self.data count],[self.data count]==1?@"Comment":@"Comments"]];
	return self.headerCell.contentView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.data count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	VTRComment *comment = self.data[indexPath.row];
	[cell.searchView.detailLabel1 setText:comment.message];
	if (comment.likes.count>0) {
		[cell.searchView.detailLabel2 setText:[NSString stringWithFormat:@"%lu",(unsigned long)[comment.likes count]]];
	}else{
		[cell.searchView.detailLabel2 setText:@""];
	}
	
	NSString *userKey = [[DataManager sharedInstance] user].key;
	if ([comment.likes containsObject:userKey] && [self.post.owner isEqualToString:userKey]) {
		[cell.searchView.button1 setImage:[UIImage imageNamed:@"ThumbsSelected"] forState:UIControlStateNormal];
	}else{
		[cell.searchView.button1 setImage:[UIImage imageNamed:@"Thumbs"] forState:UIControlStateNormal];
	}
	[cell.searchView.button1 addTarget:self action:@selector(likeComment:) forControlEvents:UIControlEventTouchUpInside];
	
	__block VTRComment *blkComment = comment;
	[[DataManager sharedInstance] getUser:comment.owner completion:^(VTRUser *user) {
		dispatch_async(dispatch_get_main_queue(), ^{
			BaseTableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.data indexOfObject:blkComment] inSection:0]];
			UIImage *placeholderImage = [UIImage imageNamed:@"default_avatar"];
			
			[cell.searchView.imageView setHidden:NO];
			// Load the image using SDWebImage
			[cell.searchView.imageView sd_setImageWithURL:user.photoURL placeholderImage:placeholderImage];
			[cell.searchView.titleLabel setText:user.displayName];
			
			if ([user.key isEqualToString:[DataManager sharedInstance].user.key]){
				[[(BRCommentCellView*)cell.searchView leadingConstraint ] setConstant:20];
			}else{
				[[(BRCommentCellView*)cell.searchView leadingConstraint ] setConstant:0];
			}
		});
	}];

	[cell.searchView.titleLabel setText:@" "];
	return cell;
}

@end
