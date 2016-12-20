//
//  TopicCollectionViewCell.h
//  Votr
//
//  Created by tmaas510 on 01/12/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *thumbImgView;
@property (strong, nonatomic) IBOutlet UILabel *titleLbl;
@property (strong, nonatomic) IBOutlet UIImageView *checkImgView;

@end
