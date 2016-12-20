//
//  MainTabVC.m
//  Votr
//
//  Created by Thomas Maas on 28/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "MainTabVC.h"
#import "CreatepollTableVC.h"

@interface MainTabVC ()

@end

@implementation MainTabVC
@synthesize btn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 28) / 2, 8, 28, 28)];
    [btn addTarget:self action:@selector(goUploadVC:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:@"tab_3"] forState:UIControlStateNormal];
    [self.tabBar addSubview:btn];
    
}

-(void)goUploadVC: (UIButton*)sender {
    NSLog(@"go challenge btn clicked!");
//    [self.tabBarController performSegueWithIdentifier:@"goUploadVCSegueID" sender:self];
//    [self.tabBarController setSelectedIndex:2];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CreatepollTableVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"CreatePollVC"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
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
