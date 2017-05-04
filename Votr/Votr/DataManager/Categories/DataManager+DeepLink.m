//
//  DataManager+DeepLink.m
//  Votr
//
//  Created by Edward Kim on 3/6/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager+DeepLink.h"
#import "VTRPost.h"

@implementation DataManager (DeepLink)


- (void)shortDeeplinkInviteForPostID:(NSString*)postID completion:(void(^)(NSError * _Nullable error,NSURL *url))_onCompletion

{

	NSDictionary *dict = @{
						   @"longDynamicLink": [NSString stringWithFormat:@"https://kan4v.app.goo.gl/?link=%@?postID%%3d%@&ibi=com.dedstop.votr",FIREBASE_URL,postID]

						   };

	//@"longDynamicLink": @"https://y85n4.app.goo.gl/?link=https://y85n4.app.goo.gl/apple-app-site-association/&ibi=com.kevin.votr"

	
	
	NSError *error;
	NSData *postData = [NSJSONSerialization dataWithJSONObject:dict
													   options:NSJSONWritingPrettyPrinted error:&error];
	
	NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
	[request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=%@",WEB_API_KEY]]];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	[[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		_onCompletion(error,[NSURL URLWithString:dict[@"shortLink"] ]);
		 //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"myappscheme://test_page/one?
	}] resume];

}

- (void)savePostID:(NSString*)postID
{
	if (postID) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:postID forKey:@"postID"];
		[defaults synchronize];
	}
}

- (NSString*)getPostID
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults objectForKey:@"postID"];
}

- (void)clearPostID
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"postID"];
	[defaults synchronize];
}

- (void)deepLinkPost:(NSString*)postID toUser:(NSString*)userID completion:(void(^)(NSError * _Nullable error))_onCompletion
{
	//Get post info
	[[[self.refDatabase child:@"posts"] child:postID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		if ([snapshot.value isKindOfClass:[NSDictionary class]]) {
			VTRPost *post = [VTRPost instanceFromDictionary:snapshot.value];
			__block typeof(VTRPost*) weakPost = post;
			if ([post.owner isEqualToString:[FIRAuth auth].currentUser.uid]) {
				_onCompletion(nil);
				return;
			}
			if (post.owner == nil) {
				_onCompletion([NSError new]);
			}
			//Get post user info
			[[[[[DataManager sharedInstance] refDatabase] child:@"users"] child:post.owner] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
				if (snapshot) {
					VTRUser *postOwner = [VTRUser instanceFromDictionary:snapshot.value];
					
					__block typeof(VTRUser*) weakPostOwner = postOwner;
					
					//Get current user info
					[[[[[DataManager sharedInstance] refDatabase] child:@"users"] child:[FIRAuth auth].currentUser.uid] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
						VTRUser *currentUser = [VTRUser instanceFromDictionary:snapshot.value];
						
						//add current user follower to postID Owner
						[weakPostOwner.followers setObject:@YES forKey:currentUser.key];
						//Add current user to following postID Owner
						[weakPostOwner.following setObject:@YES forKey:currentUser.key];
						//Add post Onwer foller to current user
						[currentUser.followers setObject:@YES forKey:weakPostOwner.key];
						//Add post Owner following to current user
						[currentUser.following setObject:@YES forKey:weakPostOwner.key];
						//Add current user to post Pvt
						[weakPost.allowedUsers setObject:@YES forKey:currentUser.key];
						
						//save data
						[[[[[DataManager sharedInstance] refDatabase] child:@"users"] child:currentUser.key] updateChildValues:[currentUser dictionaryRepresentation]];
						[[[[[DataManager sharedInstance] refDatabase] child:@"users"] child:postOwner.key] updateChildValues:[postOwner dictionaryRepresentation]];
						[[[[[DataManager sharedInstance] refDatabase] child:@"posts"] child:weakPost.key] updateChildValues:[weakPost dictionaryRepresentation]];
						_onCompletion(nil);
					}];
				}else{
					_onCompletion([NSError new]);
				}
				
			}];

		}else{
			_onCompletion([NSError new]);
		}
	}];
}
@end
