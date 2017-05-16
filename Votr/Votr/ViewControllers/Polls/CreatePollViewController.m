//
//  CreatePollViewController.m
//  Votr
//
//  Created by Edward Kim on 1/15/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "CreatePollViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "DataManager+Posts.h"
#import "DataManager+Tags.h"
#import "DataManager+Assets.h"
#import "DataManager+GIF.h"
#import "DataManager+DeepLink.h"

#import "CameraViewController.h"
#import "GIFSearchViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <WSTagsField/WSTagsField-Swift.h>
#import "BRAlertView.h"
#import "BRTextField.h"
#import "BRButton.h"

#import "BaseVoteViewController.h"
#import "InviteFollowingVIewController.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import "BRSegmentedControl.h"

@interface CreatePollViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet BRButton *postButton;
@property (strong, nonatomic) IBOutlet FLAnimatedImageView *imageView1;
@property (strong, nonatomic) IBOutlet FLAnimatedImageView *imageView2;
@property (strong, nonatomic) UIImagePickerController *picker1;
@property (strong, nonatomic) UIImagePickerController *picker2;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet WSTagsField *tagsField;
@property (strong, nonatomic) IBOutlet BRTextField *titleField;
@property (strong, nonatomic) UIView *activeView;
@property (strong, nonatomic) IBOutlet BRTextField *detailField1;
@property (strong, nonatomic) IBOutlet BRTextField *detailField2;
@property (strong, nonatomic) VTRPostItem *postItem1;
@property (strong, nonatomic) VTRPostItem *postItem2;
@property (strong, nonatomic) IBOutlet BRSegmentedControl *segmentedControl;
@property (strong, nonatomic) VTRPost *post;
@property (strong, nonatomic) NSURL *inviteURL;
@end

@implementation CreatePollViewController

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

}

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self clearPost];
	[self checkContent];
	
	[self.titleField addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
	[self.detailField1 addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
	[self.detailField2 addTarget:self action:@selector(textFieldDidChangeText:) forControlEvents:UIControlEventEditingChanged];
	[self.segmentedControl addTarget:self action:@selector(didChangeSegmentedValue:) forControlEvents:UIControlEventValueChanged];
	
	UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]
											 initWithTarget:self action:@selector(addContent:)];
	[tap1 setNumberOfTouchesRequired:1];
	UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]
											 initWithTarget:self action:@selector(addContent:)];
	[tap2 setNumberOfTouchesRequired:1];
	//Don't forget to set the userInteractionEnabled to YES, by default It's NO.
	[self.imageView1 addGestureRecognizer:tap1];
	[self.imageView2 addGestureRecognizer:tap2];

    // Do any additional setup after loading the view.
	
	self.picker1 = [[UIImagePickerController alloc] init];
	self.picker1.allowsEditing = YES;
	self.picker1.delegate = self;
	self.picker1.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	self.picker2 = [[UIImagePickerController alloc] init];
	self.picker2.allowsEditing = YES;
	self.picker2.delegate = self;
	self.picker2.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(playerItemDidReachEnd:)
												 name:AVPlayerItemDidPlayToEndTimeNotification
											   object:nil];
	
	self.tagsField.onDidChangeHeightTo = ^(WSTagsField *field, CGFloat height){
		[[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidBeginEditingNotification object:nil];
	};
	
	self.tagsField.onDidChangeText = ^(WSTagsField * _Nonnull field, NSString * _Nullable text) {
		if (text.length > 0){
			if([text characterAtIndex:0] != '_'){
				text = [NSString stringWithFormat:@"_%@",text];
				UITextField *textField = [field.subviews firstObject];
				[textField setText:text];
			}
		}
	};

	[self.scrollView setDelegate:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clearPost
{
	self.postItem1 = [VTRPostItem new];
	self.postItem2 = [VTRPostItem new];
	[self.imageView1 setImage:nil];
	[self.imageView2 setImage:nil];
	[self.imageView1.layer setSublayers:nil];
	[self.imageView1 setAnimationImages:nil];
	[self.imageView1 setAnimatedImage:nil];
	[self.imageView2.layer setSublayers:nil];
	[self.imageView2 setAnimationImages:nil];
	[self.imageView2 setAnimatedImage:nil];
	[self.detailField1 setText:nil];
	[self.detailField2 setText:nil];
	[self.titleField setText:nil];
	[self.tagsField removeTags];
	self.post = [VTRPost new];
	self.post.key = [[[[DataManager sharedInstance] refDatabase] child:@"posts"] childByAutoId].key;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"Vote"]) {
		BaseVoteViewController *controller = segue.destinationViewController;
		[controller setPost:self.post];
	}
	if ([segue.identifier isEqualToString:@"Following"]) {
		InviteFollowingViewController *controller = segue.destinationViewController;
		__weak typeof(self) weakSelf = self;
		controller.inviteUsers = ^(NSMutableDictionary *userIDs){
			weakSelf.post.allowedUsers = userIDs;
		};
	}
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
}

- (void)didChangeSegmentedValue:(UISegmentedControl*)control
{
	if (control.selectedSegmentIndex == 1) {
		[self inviteToPost:self.post.key save:NO];
	}
}

#pragma mark - Actions
- (IBAction)addContent:(id)sender
{
	__weak typeof(FLAnimatedImageView*)weakImageView;
	__weak typeof(VTRPostItem*)weakPostItem;
	__weak typeof(self) weakSelf= self;
	NSInteger index = 0;
	if ([sender isEqual:[self.imageView1.gestureRecognizers firstObject]]) {
		weakImageView = self.imageView1;
		weakPostItem = self.postItem1;
	}else{
		weakImageView = self.imageView2;
		weakPostItem = self.postItem2;
		index = 1;
	}
	
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	
	UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Take photo or video" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		dispatch_async(dispatch_get_main_queue(), ^(void){
			UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Content" bundle:nil];
			CameraViewController *controller = [storyboard instantiateInitialViewController];
			[weakSelf presentViewController:controller animated:YES completion:nil];
			[controller setIndex:index];
			controller.contentCaptured = ^(NSURL *url, UIImage *image){
				if (image) {
					weakImageView.layer.sublayers = nil;
					[weakImageView setAnimationImages:nil];
					[weakImageView setAnimatedImage:nil];
					[weakImageView setImage:image];
					[weakPostItem setData:UIImageJPEGRepresentation(image, 0.3)];
				}else {
					weakImageView.layer.sublayers = nil;
					[weakImageView setAnimationImages:nil];
					
					[weakPostItem setUrl:url];
					AVPlayer *player = [AVPlayer playerWithURL:url]; //
					player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
					
					AVPlayerLayer *layer = [AVPlayerLayer layer];
					
					[layer setPlayer:player];
					[layer setFrame:weakImageView.bounds];
					[layer setBackgroundColor:[UIColor clearColor].CGColor];
					[layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
					
					[weakImageView.layer addSublayer:layer];
					
					[player play];
				}
				
				[weakSelf checkContent];
			};
	
		});
		
	}];
	[alert addAction:camera];
	
	
	
	UIAlertAction *gif = [UIAlertAction actionWithTitle:@"GIF" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
	
		dispatch_async(dispatch_get_main_queue(), ^(void){
			UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Content" bundle:nil];
			UINavigationController *nav = [storyboard instantiateViewControllerWithIdentifier:@"gif"];
			[weakSelf presentViewController:nav animated:YES completion:nil];
			
			GIFSearchViewController *controller = [[nav viewControllers] firstObject];
			controller.contentCaptured = ^(NSURL *url){
			
				[weakPostItem setUrl:url];
				[weakSelf checkContent];
				
				[[DataManager sharedInstance] loadGIF:url onCompletion:^(NSData *data, NSError *error) {
					[weakImageView setAnimatedImage:[[FLAnimatedImage alloc] initWithAnimatedGIFData:data]];
					
				}];
				//[weakImageView sd_setImageWithURL:url];
				
			};
			
		});
	}];
	
	[alert addAction:gif];
	
	UIAlertAction *library = [UIAlertAction actionWithTitle:@"Photo library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		
		if ([sender isEqual:[self.imageView1.gestureRecognizers firstObject]]) {
			[self presentViewController:self.picker1 animated:YES completion:nil];
		}else{
			[self presentViewController:self.picker2 animated:YES completion:nil];
		}
		
	}];
	
	
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
	}];
	
	[alert addAction:library];
	[alert addAction:cancel];
	
	[self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)savePoll:(id)sender
{
	FIRDatabaseReference *postRef = [[DataManager sharedInstance] newPostReference];
	if (self.post.key){
		postRef = [[[[DataManager sharedInstance] refDatabase] child:@"posts"] child:self.post.key];
	}
	
	
	[self.postItem1 setTitle:self.detailField1.text];
	[self.postItem2 setTitle:self.detailField2.text];
	
	[self.view endEditing:YES];

	__block VTRPostItem *item1 = self.postItem1;
	[[DataManager sharedInstance] storePostItem:self.postItem1 linkToDatabaseReference:postRef completion:^(FIRStorageMetadata *metadata, NSError *error) {
		item1.url = metadata.downloadURL;
		item1.path = metadata.path;
		item1.contentType = metadata.contentType;
		[[[[[[DataManager sharedInstance] refDatabase] child:@"posts"] child:self.post.key] child:@"items"] updateChildValues:@{@"0":[item1 dictionaryRepresentation]}];
	}];
	
	__block VTRPostItem *item2 = self.postItem2;
	[[DataManager sharedInstance] storePostItem:self.postItem2 linkToDatabaseReference:postRef completion:^(FIRStorageMetadata *metadata, NSError *error) {
		item2.url = metadata.downloadURL;
		item2.path = metadata.path;
		item2.contentType = metadata.contentType;
		[[[[[[DataManager sharedInstance] refDatabase] child:@"posts"] child:self.post.key] child:@"items"] updateChildValues:@{@"1":[item2 dictionaryRepresentation]}];
	}];
	
	[[DataManager sharedInstance] setUploadStorageTaskComplete:^(NSArray *snapShots) {
		[self clearPost];
	}];
	
	
	[self.post setOwner:[FIRAuth auth].currentUser.uid];
	[self.post setTags:[[DataManager sharedInstance] pushTagStrings:[self.tagsField stringArray] reference:postRef completion:^(NSError *error, FIRDatabaseReference *ref) {
		
	}]];
	[self.post setTitle:self.titleField.text];
	[self.post setItems:@[self.postItem1,self.postItem2]];
	[self.post setEndDate:nil];
	[self.post setStartDate:nil];
	[self.post setIsPrivate:self.segmentedControl.selectedSegmentIndex == 1];
	__weak typeof(self)weakSelf = self;
	[[DataManager sharedInstance] pushPost:self.post reference:postRef completion:^(NSError *error, FIRDatabaseReference *ref) {
	
		
		if (weakSelf.postItem1.url !=nil && weakSelf.postItem2!=nil) {
			[weakSelf clearPost];
		}
		//Clear post
		//[weakSelf clearPost];
		BRAlertView *alert = [BRAlertView brandedInstanceWhiteBG];
		if (weakSelf.segmentedControl.selectedSegmentIndex == 1) {
			[alert addButton:@"Invite" validationBlock:^(void){
				return YES;
			}actionBlock:^(void) {
				[weakSelf inviteToPost:weakSelf.post.key save:YES];
			}];
		}
		
		[alert addButton:@"View Poll" validationBlock:^(void){
			return YES;
		}actionBlock:^(void) {
			[weakSelf performSegueWithIdentifier:@"Vote" sender:weakSelf.post];
		}];
		
		
		
		[alert showEdit:weakSelf title:@"Posted Successfully!" subTitle:nil closeButtonTitle:@"OK" duration:0.0f];

	}];
}

- (void)checkContent
{
	BOOL enable = YES;
	
	if (self.titleField.text.length == 0) {
		enable = NO;
	}
	
	if (self.detailField1.text.length == 0 || self.detailField2.text.length == 0) {
		enable = NO;
	}
	
	if (self.postItem1.data == nil && self.postItem1.url == nil) {
		enable = NO;
	}
	
	if (self.postItem2.data == nil && self.postItem2.url == nil) {
		enable = NO;
	}
	
	
	[self.postButton setEnabled:enable];;
}

#pragma mark - Player Notification
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
	AVPlayerItem *p = [notification object];
	[p seekToTime:kCMTimeZero];
}

#pragma mark - UITextField Delegate
- (void)textFieldDidChangeText:(id)sender
{
	[self checkContent];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self.view endEditing:YES];
}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
	if (self.picker1 == picker) {
		self.imageView1.layer.sublayers = nil;
		[self.imageView1 setImage:image];
		[self.imageView1 setAnimationImages:nil];
		[self.postItem1 setData:UIImageJPEGRepresentation(image, 0.3)];
	}else{
		self.imageView2.layer.sublayers = nil;
		[self.imageView2 setImage:image];
		[self.imageView2 setAnimationImages:nil];
		[self.postItem2 setData:UIImageJPEGRepresentation(image, 0.3)];
	}
	[self checkContent];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:^{
		//.. done dismissing
	}];
}


@end
