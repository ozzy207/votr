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
