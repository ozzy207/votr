//
//  BaseSearchCollectionViewController.m
//  Votr
//
//  Created by Edward Kim on 1/21/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseSearchCollectionViewController.h"

@interface BaseSearchCollectionViewController ()

@end

@implementation BaseSearchCollectionViewController

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - SearchBar Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}

#pragma mark - UICollectionViewFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
	CGFloat width = ((collectionView.frame.size.width-layout.minimumInteritemSpacing)-(layout.sectionInset.left+layout.sectionInset.right))/2;
	CGSize size = CGSizeMake(width, width*(12.0f/16.0f)) ;
	return size;
}

#pragma mark - UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [self.data count];
}



@end
