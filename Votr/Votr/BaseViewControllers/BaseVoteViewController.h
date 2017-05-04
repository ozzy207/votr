//
//  BaseVoteViewController.h
//  Votr
//
//  Created by Edward Kim on 2/22/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BaseTableViewController.h"
@class BRLabel,VTRPost,BRButton;
@class FLAnimatedImageView;

@interface BaseVoteViewController : BaseTableViewController
@property (strong, nonatomic) VTRPost *post;
@property (strong, nonatomic) NSString *postID;
@property (strong, nonatomic) IBOutlet BRLabel *titleLabel;
@property (strong, nonatomic) IBOutlet BRLabel *detailLabel1;
@property (strong, nonatomic) IBOutlet BRLabel *detailLabel2;
@property (strong, nonatomic) IBOutlet BRLabel *detailLabel3;
@property (strong, nonatomic) IBOutlet UIImageView *detailImageView1;
@property (strong, nonatomic) IBOutlet FLAnimatedImageView *detailImageView2;
@property (strong, nonatomic) IBOutlet FLAnimatedImageView *detailImageView3;
@property (strong, nonatomic) IBOutlet BRButton *button1;
@property (strong, nonatomic) IBOutlet BRButton *button2;

@end
