//
//  BRSelectionImageView.h
//  Votr
//
//  Created by Edward Kim on 1/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface BRSelectionImageView : UIImageView
@property (strong, nonatomic) IBInspectable NSString *overlayColor;
@property (nonatomic) IBInspectable CGFloat overlayAlpha;
@property (nonatomic) IBInspectable Boolean isSelected;
@end
