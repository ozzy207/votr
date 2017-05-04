//
//  BaseTableViewCell.h
//
//  Created by Edward Kim on 11/14/16.
//  Copyright © 2016 DedStop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRLabel.h"
#import "BRBaseSearchCellView.h"

@interface BaseTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet BRLabel *titleLabel;

@property (strong, nonatomic) IBOutlet BRLabel *detailLabel1;

@property (strong, nonatomic) IBOutlet UIImageView *detailImageView;

@property (strong, nonatomic) IBOutlet BRBaseSearchCellView *searchView;


@end
