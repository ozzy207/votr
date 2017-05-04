//
//  AuthTopicViewController.m
//  Votr
//
//  Created by Edward Kim on 1/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "AuthTopicViewController.h"
#import "DataManager+Topics.h"
#import "BRSelectionImageView.h"
#import "DataManager+User.h"
#import "DataManager+DeepLink.h"
#import "AppDelegate.h"

@import Firebase;
@import FirebaseStorageUI;

@interface AuthTopicViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation AuthTopicViewController

#pragma mark - Life Cycle
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if (self.editUser) {
		UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(next:)];
		[self.navigationItem setRightBarButtonItem:item1];
		
		UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
		[self.navigationItem setLeftBarButtonItem:item2];
	}
	
	[[DataManager sharedInstance] allTopics:^(NSArray *topics) {
		self.data = [topics mutableCopy];
		[self.collectionView reloadData];
		
		if (self.editUser) {
			//NSMutableArray *marray = [NSMutableArray new];
			NSInteger counter = 0;
			for (VTRTopic *topic in self.data) {
				if ([[DataManager sharedInstance] user].topics[topic.key]) {
					//[marray addObject:[NSIndexPath indexPathForRow:[self.data indexOfObject:topic] inSection:0]];
					[self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:counter inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
				}
				counter++;
			}
//			for (NSString *topic in [[DataManager sharedInstance] user].topics) {
//				if ([self.data containsObject:topic]) {
//					//[marray addObject:[NSIndexPath indexPathForRow:[self.data indexOfObject:topic] inSection:0]];
//					[self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:[self.data indexOfObject:topic] inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
//				}
//			}
			
			
		}

	}];
	[self.collectionView setAllowsMultipleSelection:YES];
	[self.collectionView setAllowsSelection:YES];
	[self.navigationItem.rightBarButtonItem.customView setEnabled:[self.collectionView.indexPathsForSelectedItems count]>0];
	UIButton *button = self.navigationItem.rightBarButtonItem.customView;
	button.transform = CGAffineTransformMakeScale(-1.0, 1.0);
	button.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
	button.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
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

- (IBAction)next:(id)sender
{
	//[self navigateToStoryboard:@"Main"];
	//FIRUser *user = [FIRAuth auth].currentUser;
	NSArray *selectedArray = self.collectionView.indexPathsForSelectedItems;
	selectedArray = [selectedArray valueForKeyPath:@"row"];
//	NSIndexSet *indexSet = [selectedArray indexesOfObjectsPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//		return [obj isKindOfClass:[NSNumber class]];
//	}];
	//selectedArray = [self.data objectsAtIndexes:indexSet];
	//NSArray *keys = [selectedArray valueForKey:@"key"];
	NSMutableDictionary *dict = [NSMutableDictionary new];
	for (NSNumber *numb in selectedArray) {
		[dict setValue:@YES forKey:[self.data[[numb integerValue]] key]];
	}
	
	VTRUser *user = [DataManager sharedInstance].user;
	user.topics = dict;
	[[[[[[DataManager sharedInstance] refDatabase]child:@"users"] child:user.key] child:@"topics"] setValue:dict withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
		if (self.editUser) {
			[self dismiss:self];
		}else{
			[self navigateToStoryboard:@"Main"];
			NSString *postID = [[DataManager sharedInstance] getPostID];
			if ([[DataManager sharedInstance] getPostID]) {
				[[DataManager sharedInstance] clearPostID];
				AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
				[delegate navigateModalToPost:postID];
			}
		}
	}];


//	[[[[[DataManager sharedInstance] refDatabase] child:@"users"] child:user.uid]
//	 setValue:@{@"topics": keys}];
	
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	BaseCollectionViewCell *cell = (BaseCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
	[(BRSelectionImageView*)cell.detailImageView setIsSelected:YES];
	[self.navigationItem.rightBarButtonItem.customView setEnabled:[collectionView.indexPathsForSelectedItems count]>0];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
	BaseCollectionViewCell *cell = (BaseCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
	[(BRSelectionImageView*)cell.detailImageView setIsSelected:NO];
	[self.navigationItem.rightBarButtonItem.customView setEnabled:[collectionView.indexPathsForSelectedItems count]>0];
}

- (BOOL) collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if ([collectionView.indexPathsForSelectedItems containsObject: indexPath])
	{
		[collectionView deselectItemAtIndexPath: indexPath animated: YES];
		return NO;
	}
	return YES;
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

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(BaseCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
	
	//[cell.detailImageView setImage:nil];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	VTRTopic *topic = self.data[indexPath.row];
	BaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"default" forIndexPath:indexPath];
	
	FIRStorageReference *refTopics = [[DataManager sharedInstance] refStorageTopics];
	
	FIRStorageReference *refImage = [refTopics child:[NSString stringWithFormat:@"%@.jpg",topic.key]];
	// Placeholder image
	UIImage *placeholderImage;
	[cell.detailImageView sd_setImageWithStorageReference:refImage placeholderImage:placeholderImage];
	[cell.titleLabel setText:topic.title];
	NSArray *selectedIndexPaths = [collectionView indexPathsForSelectedItems];

	[(BRSelectionImageView*)cell.detailImageView setIsSelected:[selectedIndexPaths containsObject:indexPath]];

	return cell;
}
@end
