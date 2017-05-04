//
//  ViewController.m
//
//  Created by Edward Kim on 10/18/16.
//  Copyright © 2016 DedStop. All rights reserved.
//

#import "BaseViewController.h"
#import "AppDelegate.h"
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import "DataManager+DeepLink.h"
#import "VTRPost.h"
#import <MessageUI/MessageUI.h>
#import "MFMailComposeViewController+Style.h"

@import Firebase;

@interface BaseViewController ()<FIRInviteDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@end

@implementation BaseViewController

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.handles = [NSMutableArray new];
	[self setNeedsStatusBarAppearanceUpdate];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}


#pragma mark - Navigation
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)home:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)modal:(id)sender
{
    UINavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"Modal"];
    [self presentViewController:nav animated:YES completion:nil]; //Missing
}

- (IBAction)unwind:(UIStoryboardSegue*)sender
{
    
}

- (IBAction)logout:(id)sender
{
	NSError *signOutError;
	BOOL status = [[FIRAuth auth] signOut:&signOutError];
	[DataManager sharedInstance].user = nil;
	FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
	[manager logOut];
	if (!status) {
		NSLog(@"Error signing out: %@", signOutError);

	}else{
		[self navigateToStoryboard:@"Auth"];
	}
}

- (void)navigateToStoryboard:(NSString*)storyboardName
{
	AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
	UIViewController *controller = [storyboard instantiateInitialViewController];
	appDelegate.window.rootViewController = controller;
	[appDelegate.window makeKeyAndVisible];
	
	controller.view.alpha = 0.0;
	
	[UIView animateWithDuration:0.3 animations:^{
		
		controller.view.alpha = 1.0;
		
	}];
}

- (BOOL)hasAccessToPost:(VTRPost*)post
{
	return [[post.allowedUsers objectForKey:[FIRAuth auth].currentUser.uid] boolValue];
}

- (NSURL *)applicationDocumentsDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)tearDownObservers
{
	for (VTRHandle *handle in self.handles){
		[handle.reference removeObserverWithHandle:handle.handle];
	}
}

- (void)inviteToPost:(NSString*)postKey save:(BOOL)save
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Votr" message:@"Invite user to poll" preferredStyle:UIAlertControllerStyleActionSheet];
	UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Votr User" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self performSegueWithIdentifier:@"Following" sender:@(save)];
	}];
	
	UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Email Invite" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[[DataManager sharedInstance] shortDeeplinkInviteForPostID:postKey completion:^(NSError * _Nullable error, NSURL *url) {
			if (!error) {
				[self sendEmailInvite:url];
			}
		}];
		
	}];
	
	UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"Text Invite" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[[DataManager sharedInstance] shortDeeplinkInviteForPostID:postKey completion:^(NSError * _Nullable error, NSURL *url) {
			if (!error) {
				[self sendMessageInvite:url];
			}
		}];
		
	}];
	
	UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
	}];
	
	[alert addAction:action1];
	[alert addAction:action2];
	[alert addAction:action3];
	[alert addAction:action4];
	[self presentViewController:alert animated:YES completion:nil];
}

- (void)inviteFinishedWithInvitations:(NSArray *)invitationIds error:(NSError *)error {
	NSString *message =
	error ? error.localizedDescription
	: [NSString stringWithFormat:@"%lu invites sent", (unsigned long)invitationIds.count];
	
	UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
													   style:UIAlertActionStyleDefault
													 handler:^(UIAlertAction *action) {
														 NSLog(@"OK");
													 }];
	
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Done"
																			 message:message
																	  preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:okAction];
	[self presentViewController:alertController
					   animated:YES
					 completion:nil];
}

- (void)sendEmailInvite:(NSURL*)url
{
	if(![MFMailComposeViewController canSendMail]){
		return;
	}
	
	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	[[controller navigationBar] setTintColor:self.navigationController.navigationBar.tintColor];
	[[controller navigationBar] setBarTintColor:self.navigationController.navigationBar.barTintColor];
	
	[controller setSubject:@"Votr Invite"];
	NSString *htmlString = @"<font size = '2' color= \"#000000\" style = \"font-family:Helvetica;\">Votr App Invite<br/></font><a href=\"%@\">Click here</a></font>";
	[controller setMessageBody:[NSString stringWithFormat:htmlString,[url absoluteString]] isHTML:YES];
	[controller setMailComposeDelegate:self];
	[self presentViewController:controller animated:YES completion:^{
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	}];
}

- (void)sendMessageInvite:(NSURL*)url
{
	if(![MFMessageComposeViewController canSendText]){
		return;
	}
	
	MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
	[[controller navigationBar] setTintColor:self.navigationController.navigationBar.tintColor];
	[[controller navigationBar] setBarTintColor:self.navigationController.navigationBar.barTintColor];
	[controller setSubject:@"Votr Invite"];
	[controller setBody:[NSString stringWithFormat:@"Click on this link %@",[url absoluteString]]];
	[controller setMessageComposeDelegate:self];
	[self presentViewController:controller animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	[self dismiss:controller];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismiss:controller];
}
@end
