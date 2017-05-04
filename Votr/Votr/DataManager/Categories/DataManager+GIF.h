//
//  DataManager+GIF.h
//  Votr
//
//  Created by Edward Kim on 1/21/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager.h"

@interface DataManager (GIF)
- (void)GIFSearch:(NSString*)search onCompletion:(void(^)(NSMutableArray *gifURLs))_onCompletion;
- (void)loadGIF:(NSURL*)url onCompletion:(void(^)(NSData *data, NSError *error))_onCompletion;
@end
