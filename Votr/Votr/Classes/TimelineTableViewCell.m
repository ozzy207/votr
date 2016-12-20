//
//  TimelineTableViewCell.m
//  Votr
//
//  Created by tmaas510 on 23/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "TimelineTableViewCell.h"

@implementation TimelineTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.bgView.layer.cornerRadius = 3;
    self.bgView.layer.masksToBounds = YES;
    
    self.avatarImg.layer.cornerRadius = 10; //self.avatarImg.frame.size.width / 2;
    self.avatarImg.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
