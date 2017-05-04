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
#import "BRAlertView.h"
#import "DataManager+Topics.h"
#import "BRButton.h"
#import "DataManager+User.h"
#import "DataManager+DeepLink.h"

@import GoogleSignIn;
@import Firebase;

@interface AuthLandingViewController ()<GIDSignInDelegate,
GIDSignInUIDelegate>
@property (strong, nonatomic) IBOutlet BRButton *facebookBtn;
@property (strong, nonatomic) IBOutlet BRButton *googleBtn;
@property (strong, nonatomic) IBOutlet BRButton *userBtn;
@property (strong, nonatomic) IBOutlet BRButton *userCreateBtn;

@end

@implementation AuthLandingViewController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES];
}

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

- (void)enableBtns:(BOOL)enable
{
	[self.googleBtn setEnabled:enable];
	[self.facebookBtn setEnabled:enable];
	[self.userCreateBtn setEnabled:enable];
	[self.userBtn setEnabled:enable];
}

#pragma mark - User Login
- (IBAction)signIn:(id)sender
{
	
	BRAlertView *alert = [BRAlertView brandedInstance];
	UITextField *textField1 = [alert addTextField:@"Enter Email"];
	UITextField *textField2 = [alert addTextField:@"Enter Password"];
	[textField2 setSecureTextEntry:YES];
	[alert addButton:@"Continue" actionBlock:^(void) {
		//NSLog(@"Text value: %@", textField.text);
		[[FIRAuth auth] signInWithEmail:textField1.text
							   password:textField2.text
							 completion:^(FIRUser *user, NSError *error) {
								 
								 if (error) {
									 BRAlertView *alert = [BRAlertView brandedInstance];
									 [alert showError:self title:@"Error" subTitle:error.localizedDescription closeButtonTitle:@"OK" duration:0.0f];
								 }else{
									 [self getUserTopics:user];
								 }
							 }];
	}];
	
	[alert showEdit:self title:@"Sign in" subTitle:nil closeButtonTitle:@"Cancel" duration:0.0f];
}

- (IBAction)signUp:(id)sender
{
	BRAlertView *alert = [BRAlertView brandedInstance];
	
	UITextField *textField1 = [alert addTextField:@"Enter Email"];
	UITextField *textField2 = [alert addTextField:@"Enter Password"];
	UITextField *textField3 = [alert addTextField:@"Confirm Password"];
	UITextField *textField4 = [alert addTextField:@"User Name"];
	[textField2 setSecureTextEntry:YES];
	[textField3 setSecureTextEntry:YES];
	__weak typeof(BRAlertView*)weakAlert = alert;
	[alert addButton:@"Continue" validationBlock:^(void){
		if (![textField2.text isEqualToString:textField3.text]) {

			[weakAlert.labelTitle setText:@"Password mismatch!"];
			return NO;
		}
		
		return YES;
	}actionBlock:^(void) {
		[self enableBtns:NO];
		[[FIRAuth auth]
		 createUserWithEmail:textField1.text
		 password:textField2.text
		 completion:^(FIRUser *_Nullable user,
					  NSError *_Nullable error) {
			 if(error){
				 [self enableBtns:YES];
				 BRAlertView *alert = [BRAlertView brandedInstance];
				 [alert showError:self title:@"Error" subTitle:error.localizedDescription closeButtonTitle:@"OK" duration:0.0f];
			 }else{
				 VTRUser *vuser = [DataManager sharedInstance].user;
				 [vuser setDisplayName:textField4.text];
				 [vuser setKey:user.uid];
				 //[vuser setPhotoURL:user.photoURL];
				 [[DataManager sharedInstance] updateUser:vuser onCompletion:nil];
				 [self getUserTopics:user];
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
								  [self enableBtns:YES];
								  if (error) {
									  BRAlertView *alert = [BRAlertView brandedInstance];
									  [alert showError:self title:@"Error" subTitle:error.localizedDescription closeButtonTitle:@"OK" duration:0.0f];
									  
								  }else{
									  VTRUser *vuser = [DataManager sharedInstance].user;
									  [vuser setDisplayName:user.displayName];
									  [vuser setKey:user.uid];
									  [vuser setPhotoURL:user.photoURL];
									  [[DataManager sharedInstance] updateUser:vuser onCompletion:nil];
									  [self getUserTopics:user];
								  }
							  }];
}

#pragma mark - Facebook Delegate
- (IBAction)facebookSignin:(UIButton*)sender
{
	[self enableBtns:NO];
	FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
	[login logInWithReadPermissions:@[@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
		if (error) {
			// Process error
			[self enableBtns:YES];
			BRAlertView *alert = [BRAlertView brandedInstance];
			[alert showError:self title:@"Error" subTitle:error.localizedDescription closeButtonTitle:@"OK" duration:0.0f];
		} else if (result.isCancelled) {
			// Handle cancellations
			[self enableBtns:YES];
		} else {
			FIRAuthCredential *credential = [FIRFacebookAuthProvider
											 credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
											 .tokenString];
			
			[self firebaseAuthenticate:credential];
		}
	}];
}

//Not used anymore since using custom button vs FBSDKLoginButton
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
- (IBAction)googleSignin:(id)sender
{
	[self enableBtns:NO];
	[[GIDSignIn sharedInstance] signIn];
}

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
	 withError:(NSError *)error {
	[self enableBtns:YES];
	if (error == nil) {
		
		GIDAuthentication *authentication = user.authentication;
		FIRAuthCredential *credential =
		[FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken
										 accessToken:authentication.accessToken];
		[self firebaseAuthenticate:credential];
	} else{
		BRAlertView *alert = [BRAlertView brandedInstance];
		[alert showError:self title:@"Error" subTitle:error.localizedDescription closeButtonTitle:@"OK" duration:0.0f];
	}
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
	 withError:(NSError *)error
{
	[self enableBtns:YES];
	// Perform any operations when the user disconnects from app here.
	// ...
}

#pragma mark - userTopics
- (void)getUserTopics:(FIRUser*)user
{
	[self enableBtns:NO];
	[[DataManager sharedInstance] initialize];
	[[DataManager sharedInstance] userTopics:user.uid onCompletion:^(NSArray *topics) {
		[self enableBtns:YES];
		if (![topics respondsToSelector:@selector(count)]) {
			[self performSegueWithIdentifier:@"topics" sender:nil];
			
		}else{
			if ([topics count]<=0) {
				[self performSegueWithIdentifier:@"topics" sender:nil];
			}else{
				[self navigateToStoryboard:@"Main"];
				NSString *postID = [[DataManager sharedInstance] getPostID];
				if (postID) {
					[[DataManager sharedInstance] deepLinkPost:postID toUser:[FIRAuth auth].currentUser.uid completion:^(NSError *error) {
						NSLog(@"linked");
						//Navigate to Post
						[[DataManager sharedInstance] clearPostID];
						if (!error) {
							AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
							[delegate navigateModalToPost:postID];
						}
						
					}];
					
				}
			}
			
		}
	}];
}

@end
