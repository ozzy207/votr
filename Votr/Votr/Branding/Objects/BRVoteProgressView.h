//
//  BRVoteProgressView.h
//  Votr
//
//  Created by Edward Kim on 2/26/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BRBaseXibView.h"

@class BRLabel;

IB_DESIGNABLE
@interface BRVoteProgressView : BRBaseXibView
@property (nonatomic) IBInspectable CGFloat lineWidth;
@property (nonatomic) IBInspectable CGFloat percentage;
@property (strong, nonatomic) IBInspectable NSString *colorCode;
@property (strong, nonatomic) IBOutlet BRLabel *detailLabel;
@property (nonatomic, copy) void (^progress)(double percentage);
@property (nonatomic, copy) void (^completion)();
- (void)resetAnimation;
- (void)changePercentage:(CGFloat)percentage;
@end
