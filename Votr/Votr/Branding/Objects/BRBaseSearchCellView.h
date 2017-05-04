//
//  BRBaseSearchCell.h
//  Votr
//
//  Created by Edward Kim on 2/20/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BRBaseXibView.h"
@class BRLabel,BRView;

@interface BRBaseSearchCellView : BRBaseXibView
@property (strong, nonatomic) IBOutlet BRView *statusView;
@property (strong, nonatomic) IBOutlet BRLabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet BRLabel *detailLabel1;
@property (strong, nonatomic) IBOutlet BRLabel *detailLabel2;
@property (strong, nonatomic) IBOutlet BRLabel *detailLabel3;
@property (strong, nonatomic) IBOutlet UIStackView *detailStackView;
@property (strong, nonatomic) IBOutlet UIButton *button1;

@end
