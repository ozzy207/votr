//
//  ViewController.h
//
//  Created by Edward Kim on 10/18/16.
//  Copyright © 2016 DedStop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
//@interface BaseImageViewController : UIImageView
- (void)navigateToStoryboard:(NSString*)storyboardName;
- (IBAction)back:(id)sender;
- (IBAction)home:(id)sender;
- (IBAction)dismiss:(id)sender;
- (IBAction)modal:(id)sender;
- (IBAction)unwind:(UIStoryboardSegue*)sender;
@end

