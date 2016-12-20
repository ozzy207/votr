//
//  TopicsViewController.m
//  Votr
//
//  Created by tmaas510 on 01/12/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "TopicsViewController.h"
#import "TopicCollectionViewCell.h"

@interface TopicsViewController () <UICollectionViewDelegate> {
    NSArray *list;
    NSMutableArray *checklist;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextBarItem;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionview;

@end

@implementation TopicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    list = @[@"Entertainment", @"Fashion", @"Celebrity", @"Animals", @"Travel", @"Food", @"Funny", @"Politics", @"Art", @"Sports", @"Lifestyle", @"Finance", @"Science", @"Photography", @"Health", @"News"];
    checklist = [[NSMutableArray alloc] init];
//    [self.collectionview reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextAction:(id)sender {
    PFUser *user = [PFUser currentUser];
    user[kTopics] = checklist;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded == YES && !error){
            NSLog(@"Save Success!");
            [self performSegueWithIdentifier:@"topicToTabSegue" sender:self];
        }else{
            NSString *errorString = [error userInfo][@"error"];
            [Utils createAlert:msg_e_error withMessage:errorString];
            return;
        }
    }];
}

#pragma mark - UICollectionView Stuff

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((collectionView.frame.size.width - 26)/2, (collectionView.frame.size.width - 26)/2 * 0.75);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return list.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TopicCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"topicCollectionCellId" forIndexPath:indexPath];
    cell.thumbImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", list[indexPath.item]]];
    cell.titleLbl.text = [NSString stringWithFormat:@"%@", list[indexPath.item]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TopicCollectionViewCell *cell = (TopicCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell.checkImgView.isHidden == YES) {
        [cell.checkImgView setHidden:NO];
        [checklist addObject:list[indexPath.item]];
        if (checklist.count >= 5 && _nextBarItem.isEnabled == false) {
            [_nextBarItem setEnabled:YES];
        }
    } else {
        [cell.checkImgView setHidden:YES];
        [checklist removeObject:list[indexPath.item]];
        if (checklist.count < 5 && _nextBarItem.isEnabled == true) {
            [_nextBarItem setEnabled:NO];
        }
    }
    
//    NSInteger rowcount =  [[collectionView indexPathsForSelectedItems] count];
//    NSLog(@"selected cell count = %ld", rowcount);
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"deselected");
}

@end
