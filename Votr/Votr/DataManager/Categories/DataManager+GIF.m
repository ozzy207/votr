//
//  DataManager+GIF.m
//  Votr
//
//  Created by Edward Kim on 1/21/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "DataManager+GIF.h"

#define GIF_URL_STRING @"http://media2.giphy.com/media/%@/200w_d.gif"
#define GIF_TRENDING_URL_STRING @"http://api.giphy.com/v1/gifs/trending?api_key=dc6zaTOxFJmzC"

@implementation DataManager (GIF)


- (void)GIFSearch:(NSString*)search onCompletion:(void(^)(NSMutableArray *gifURLs))_onCompletion
{
	if (search == nil) {
		search = GIF_TRENDING_URL_STRING;
	}
	if (search.length == 0) {
		search = GIF_TRENDING_URL_STRING;
	}
	search = [search stringByReplacingOccurrencesOfString:@" " withString:@"+"];

	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.giphy.com/v1/gifs/search?q=%@&api_key=dc6zaTOxFJmzC",search]];
	[[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
		NSArray *arrayIDs = [[dict objectForKey:@"data"] valueForKeyPath:@"id"];
		NSMutableArray *urlArray = [NSMutableArray new];
		for (NSString *gifID in arrayIDs) {
			[urlArray addObject:[NSURL URLWithString:[NSString stringWithFormat:GIF_URL_STRING,gifID]]];
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			_onCompletion(urlArray);
		});
		
	}] resume];
}

- (void)loadGIF:(NSURL*)url onCompletion:(void(^)(NSData *data, NSError *error))_onCompletion
{
	[[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			_onCompletion(data,error);
		});
		
	}] resume];
}
@end
