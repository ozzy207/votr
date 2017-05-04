//
//  GIFSearchViewController.m
//  Votr
//
//  Created by Edward Kim on 1/21/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "GIFSearchViewController.h"
#import "DataManager+GIF.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface GIFSearchViewController ()

@end

@implementation GIFSearchViewController

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	[[DataManager sharedInstance] GIFSearch:nil onCompletion:^(NSMutableArray *gifURLs) {
		self.data = gifURLs;
		[self.collectionView reloadData];
	}];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UISearchBar Delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[[DataManager sharedInstance] GIFSearch:searchText onCompletion:^(NSMutableArray *gifURLs) {
		self.data = gifURLs;
		[self.collectionView reloadData];
	}];
}

#pragma mark - UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSURL *url = self.data[indexPath.row];
	if ([[url absoluteString] containsString:@".gif"]) {
		NSString *string = [url absoluteString];
		string = [string stringByReplacingOccurrencesOfString:@"200w_d" withString:@"giphy"];
		url = [NSURL URLWithString:string];
	}
	self.contentCaptured(url);
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView DataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSURL *gifURL = self.data[indexPath.row];
	BaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"default" forIndexPath:indexPath];
	
	[cell.detailImageView sd_setImageWithURL:gifURL];
	return cell;
}
@end
