//
//  BRAlertView.m
//  Votr
//
//  Created by Edward Kim on 1/7/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "BRAlertView.h"

@interface BRAlertView ()

@end

@implementation BRAlertView


+ (instancetype)brandedInstance
{
	BRAlertView *alert = [[BRAlertView alloc] init];
	[alert.labelTitle setTextColor:[[Branding shareInstance] color:@"K"]];
	[alert.viewText setTextColor:[[Branding shareInstance] color:@"K"]];
	alert.showAnimationType =  SCLAlertViewShowAnimationFadeIn;
	
	//Set background type (Default is SCLAlertViewBackgroundShadow)
	alert.backgroundType = SCLAlertViewBackgroundBlur;
	
	//Overwrite SCLAlertView (Buttons, top circle and borders) colors
	alert.customViewColor = [[Branding shareInstance] color:@"G"];
	
	//Set custom tint color for icon image.
	alert.iconTintColor = [[Branding shareInstance] color:@"K"];
	
	//Overwrite SCLAlertView background color
	alert.backgroundViewColor = [[Branding shareInstance] color:@"B"];
	return alert;
}

+ (instancetype)brandedInstanceWhiteBG
{
	BRAlertView *alert = [[BRAlertView alloc] init];
	[alert.labelTitle setTextColor:[[Branding shareInstance] color:@"B"]];
	[alert.viewText setTextColor:[[Branding shareInstance] color:@"B"]];
	alert.showAnimationType =  SCLAlertViewShowAnimationFadeIn;
	
	//Set background type (Default is SCLAlertViewBackgroundShadow)
	alert.backgroundType = SCLAlertViewBackgroundBlur;
	
	//Overwrite SCLAlertView (Buttons, top circle and borders) colors
	alert.customViewColor = [[Branding shareInstance] color:@"G"];
	
	//Set custom tint color for icon image.
	alert.iconTintColor = [[Branding shareInstance] color:@"K"];
	
	//Overwrite SCLAlertView background color
	alert.backgroundViewColor = [[Branding shareInstance] color:@"K"];
	return alert;
}


#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
