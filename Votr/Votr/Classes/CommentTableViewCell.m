//
//  CommentTableViewCell.m
//  Votr
//
//  Created by tmaas510 on 30/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.avatarImg.layer.cornerRadius = 15; //self.avatarImg.frame.size.width / 2;
    self.avatarImg.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
