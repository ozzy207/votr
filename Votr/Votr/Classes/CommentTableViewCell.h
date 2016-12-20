//
//  CommentTableViewCell.h
//  Votr
//
//  Created by tmaas510 on 30/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatarImg;
@property (strong, nonatomic) IBOutlet UILabel *commentLbl;
@property (strong, nonatomic) IBOutlet UIButton *likeBtn;
@property (strong, nonatomic) IBOutlet UIButton *unlikeBtn;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentLblHeight;
@property (strong, nonatomic) IBOutlet UILabel *likeCountLbl;

@end
