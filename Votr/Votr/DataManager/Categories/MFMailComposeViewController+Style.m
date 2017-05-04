//
//  MFMailComposeViewController+Style.m
//  Votr
//
//  Created by Edward Kim on 3/8/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "MFMailComposeViewController+Style.h"

@implementation MFMailComposeViewController (Style)

-(UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

-(UIViewController *)childViewControllerForStatusBarStyle
{
	return nil;
}

@end
