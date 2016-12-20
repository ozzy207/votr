//
//  TimelineTableViewCell.h
//  Votr
//
//  Created by tmaas510 on 23/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIView *bgView;
@property (strong, nonatomic) IBOutlet UIView *pollTyleView;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImg;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UILabel *timeLbl;
@property (strong, nonatomic) IBOutlet UILabel *commentNumLbl;
@property (strong, nonatomic) IBOutlet UILabel *voteNumLbl;
@property (strong, nonatomic) IBOutlet UIImageView *alertImgView;

@end
