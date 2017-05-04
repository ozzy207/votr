//
//  DataManager+DeepLink.h
//  Votr
//
//  Created by Edward Kim on 3/6/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager.h"

@interface DataManager (DeepLink)
- (void)shortDeeplinkInviteForPostID:(NSString*)postID completion:(void(^)(NSError * _Nullable error,NSURL *url))_onCompletion;
- (void)savePostID:(NSString*)postID;
- (NSString*)getPostID;
- (void)clearPostID;
- (void)deepLinkPost:(NSString*)postID toUser:(NSString*)userID completion:(void(^)(NSError * error))_onCompletion;
@end
