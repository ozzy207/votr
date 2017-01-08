//
//  BaseCollectionViewCell.h
//  Votr
//
//  Created by Edward Kim on 1/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRLabel.h"

@interface BaseCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet BRLabel *titleLabel;

@property (strong, nonatomic) IBOutlet BRLabel *detaiLabel1;

@property (strong, nonatomic) IBOutlet UIImageView *detailImageView;

@end
