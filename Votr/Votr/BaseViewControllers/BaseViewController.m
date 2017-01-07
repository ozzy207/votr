//
//  ViewController.m
//
//  Created by Edward Kim on 10/18/16.
//  Copyright © 2016 DedStop. All rights reserved.
//

#import "BaseViewController.h"
#import "AppDelegate.h"
#import <FBSDKLoginKit/FBSDKLoginManager.h>

@import Firebase;

@interface BaseViewController ()

@end

@implementation BaseViewController

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

- (IBAction)login:(id)sender
{
	[self navigateToStoryboard:@"Main"];
}

- (IBAction)logout:(id)sender
{
	NSError *signOutError;
	BOOL status = [[FIRAuth auth] signOut:&signOutError];
	
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

@end
