//
//  AppDelegate.m
//  Votr
//
//  Created by Edward Kim on 01/06/16.
//  Copyright © 2016 DEDStop LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Branding.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "DataManager.h"
#import "DataManager+DeepLink.h"
#import "JLRoutes.h"
#import "BaseVoteViewController.h"

@import GoogleSignIn;
@import Firebase;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

	
	[GIDSignIn sharedInstance].clientID = [FIRApp defaultApp].options.clientID;
	
	[[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
	
	[[Branding shareInstance] intitialize];
	
	[FIROptions defaultOptions].deepLinkURLScheme = URLSCHEME;
	
	[FIRApp configure];
	
	//[[FIRAuth auth] signOut:nil];
	if ([FIRAuth auth].currentUser) {// User is signed in.

	} else { // No user is signed in.
		UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Auth" bundle:nil];
		UIViewController *controller = [storyboard instantiateInitialViewController];
		//UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Auth" bundle:nil];
		//UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"topics"];
		self.window.rootViewController = controller;
		[self.window makeKeyAndVisible];
	}
	
	[[DataManager sharedInstance] initialize];
	
	
	[[JLRoutes globalRoutes] addRoute:@":domain" handler:^BOOL(NSDictionary *parameters) {
		NSString *postID = parameters[@"postID"];
		if ([FIRAuth auth].currentUser) {
			[[DataManager sharedInstance] deepLinkPost:postID toUser:[FIRAuth auth].currentUser.uid completion:^(NSError *error) {
				NSLog(@"linked");
				//Navigate to Post
				if (!error){
					[self navigateModalToPost:postID];
				}
			}];
			
		}else{
			//If new user
			//Save postID and repeat above post login
			[[DataManager sharedInstance] savePostID:postID];
		}

		return YES; // return YES to say we have handled the route
	}];
	// ..
	
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //[FBSDKAppEvents activateApp];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    //[self saveContext];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	
	BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
																  openURL:url
														sourceApplication:sourceApplication
															   annotation:annotation
					];
	if (!handled) {
		handled = [[GIDSignIn sharedInstance] handleURL:url
									  sourceApplication:sourceApplication
											 annotation:annotation];
	}
	
//	FIRReceivedInvite *invite =
//	[FIRInvites handleURL:url sourceApplication:sourceApplication annotation:annotation];
//	if (invite) {
//		NSString *matchType =
//		(invite.matchType == FIRReceivedInviteMatchTypeWeak) ? @"Weak" : @"Strong";
//		NSString *message =
//		[NSString stringWithFormat:@"Deep link from %@ \nInvite ID: %@\nApp URL: %@\nMatch Type:%@",
//		 sourceApplication, invite.inviteId, invite.deepLink, matchType];
//		NSLog(@"%@",message);
////		[[[UIAlertView alloc] initWithTitle:@"Deep-link Data"
////									message:message
////								   delegate:nil
////						  cancelButtonTitle:@"OK"
////						  otherButtonTitles:nil] show];
//		
//		return YES;
//	}
	// Add any custom logic here.
	return handled;
}

- (BOOL)application:(nonnull UIApplication *)application
			openURL:(nonnull NSURL *)url
			options:(nonnull NSDictionary<NSString *, id> *)options
{
	BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
																  openURL:url
														sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
															   annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
	if (!handled) {
		handled = [[GIDSignIn sharedInstance] handleURL:url
									  sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
											 annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
	}
	
	if (!handled) {
		FIRDynamicLink *dynamicLink =
		[[FIRDynamicLinks dynamicLinks] dynamicLinkFromCustomSchemeURL:url];
		
		if (dynamicLink) {
			NSString *link = dynamicLink.url;
			BOOL strongMatch = dynamicLink.matchConfidence == FIRDynamicLinkMatchConfidenceStrong;
			// ...
			// Handle the deep link. For example, show the deep-linked content or
			// apply a promotional offer to the user's account.
			// ...
			[JLRoutes routeURL:dynamicLink.url];
			return YES;
		}
	}


	return handled;
}

- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray *))restorationHandler {
	
	BOOL handled = [[FIRDynamicLinks dynamicLinks]
					handleUniversalLink:userActivity.webpageURL
					completion:^(FIRDynamicLink * _Nullable dynamicLink,
								 NSError * _Nullable error) {
						// ...
						NSString *link = dynamicLink.url;
						BOOL strongMatch = dynamicLink.matchConfidence == FIRDynamicLinkMatchConfidenceStrong;
						[JLRoutes routeURL:dynamicLink.url];
						// ...
					}];
	
	
	return handled;
}

- (void)navigateModalToPost:(NSString*)postID
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Poll" bundle:nil];
	BaseVoteViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"Vote"];
	[controller setPostID:postID];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
	[self.window.rootViewController presentViewController:nav animated:YES completion:nil];
}

@end
