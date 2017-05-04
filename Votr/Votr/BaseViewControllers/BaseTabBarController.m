//
//  BaseTabBarController.m
//
//  Created by Edward Kim on 11/7/16.
//  Copyright © 2016 DedStop. All rights reserved.
//

#import "BaseTabBarController.h"
#import "Branding.h"
#import "UIImage+Overlay.h"

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UITabBar appearance] setBarTintColor:[[Branding shareInstance] color:@"A"]];
    [[UITabBar appearance] setTintColor:[[Branding shareInstance]  color:@"E"]];
    
    [self setNeedsStatusBarAppearanceUpdate];
	
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[[Branding shareInstance]  color:@"E"], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];

    
    // set color of unselected text
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[[Branding shareInstance]  color:@"B"], NSForegroundColorAttributeName, nil]
                                             forState:UIControlStateNormal];
    
    // generate a tinted unselected image based on image passed via the storyboard
    for(UITabBarItem *item in self.tabBar.items) {
        // use the UIImage category code for the imageWithColor: method
        item.image = [[item.selectedImage imageWithColor:[[Branding shareInstance]  color:@"B"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
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
