//
//  AuthLandingViewController.m
//  Votr
//
//  Created by Edward Kim on 1/6/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "AuthLandingViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "SCLAlertView.h"
@import GoogleSignIn;
@import Firebase;

@interface AuthLandingViewController ()<GIDSignInDelegate,
GIDSignInUIDelegate>

@end

@implementation AuthLandingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[GIDSignIn sharedInstance].uiDelegate = self;
	[GIDSignIn sharedInstance].delegate = self;
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

#pragma mark - User Login
- (IBAction)signIn:(id)sender
{
	SCLAlertView *alert = [[SCLAlertView alloc] init];
	[alert.labelTitle setTextColor:[[Branding shareInstance] color:@"K"]];
	alert.showAnimationType =  SCLAlertViewShowAnimationFadeIn;
	
	//Set background type (Default is SCLAlertViewBackgroundShadow)
	alert.backgroundType = SCLAlertViewBackgroundBlur;
	
	//Overwrite SCLAlertView (Buttons, top circle and borders) colors
	alert.customViewColor = [[Branding shareInstance] color:@"G"];
	
	//Set custom tint color for icon image.
	alert.iconTintColor = [[Branding shareInstance] color:@"K"];
	
	//Overwrite SCLAlertView background color
	alert.backgroundViewColor = [[Branding shareInstance] color:@"B"];
	
	UITextField *textField1 = [alert addTextField:@"Enter Email"];
	UITextField *textField2 = [alert addTextField:@"Enter Password"];
	[alert addButton:@"Continue" actionBlock:^(void) {
		//NSLog(@"Text value: %@", textField.text);
		[[FIRAuth auth] signInWithEmail:textField1.text
							   password:textField2.text
							 completion:^(FIRUser *user, NSError *error) {
								 // ...
								 [self login:nil];
							 }];
	}];
	
	[alert showEdit:self title:@"Sign in" subTitle:nil closeButtonTitle:@"Cancel" duration:0.0f];
}

- (IBAction)signUp:(id)sender
{
	SCLAlertView *alert = [[SCLAlertView alloc] init];
	[alert.labelTitle setTextColor:[[Branding shareInstance] color:@"K"]];
	alert.showAnimationType =  SCLAlertViewShowAnimationFadeIn;
	
	//Set background type (Default is SCLAlertViewBackgroundShadow)
	alert.backgroundType = SCLAlertViewBackgroundBlur;
	
	//Overwrite SCLAlertView (Buttons, top circle and borders) colors
	alert.customViewColor = [[Branding shareInstance] color:@"G"];
	
	//Set custom tint color for icon image.
	alert.iconTintColor = [[Branding shareInstance] color:@"K"];
	
	//Overwrite SCLAlertView background color
	alert.backgroundViewColor = [[Branding shareInstance] color:@"B"];
	
	UITextField *textField1 = [alert addTextField:@"Enter Email"];
	UITextField *textField2 = [alert addTextField:@"Enter Password"];
	
	[alert addButton:@"Continue" actionBlock:^(void) {
		[[FIRAuth auth]
		 createUserWithEmail:textField1.text
		 password:textField2.text
		 completion:^(FIRUser *_Nullable user,
					  NSError *_Nullable error) {
			 if(error){
				 
			 }else{
				 [self login:nil];
			 }
			 // ...
		 }];
	}];
	
	[alert showEdit:self title:@"Sign up" subTitle:nil closeButtonTitle:@"Cancel" duration:0.0f];
}

#pragma mark - Firebase
- (void)firebaseAuthenticate:(FIRAuthCredential*)credential
{
	[[FIRAuth auth] signInWithCredential:credential
							  completion:^(FIRUser *user, NSError *error) {
								  // ...
								  
								  if (error) {
									  // ...
									  return;
								  }else{
									  [self login:nil];
								  }
							  }];
}

#pragma mark - Facebook Delegate
- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
			  error:(NSError *)error
{
	if (error == nil) {
		// ...
		FIRAuthCredential *credential = [FIRFacebookAuthProvider
										 credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
										 .tokenString];
										 
		[self firebaseAuthenticate:credential];
	} else {
		//NSLog(error.localizedDescription);
	}

}

#pragma mark - Google Delegate
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
	 withError:(NSError *)error {
	if (error == nil) {
		GIDAuthentication *authentication = user.authentication;
		FIRAuthCredential *credential =
		[FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
										 accessToken:authentication.accessToken];
		[self firebaseAuthenticate:credential];
	} else{
	
	}
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
	 withError:(NSError *)error
{
	// Perform any operations when the user disconnects from app here.
	// ...
}

@end
