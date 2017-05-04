//
//  ViewController.h
//
//  Created by Edward Kim on 10/18/16.
//  Copyright © 2016 DedStop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTRHandle.h"
@class VTRPost;

@interface BaseViewController : UIViewController
@property (strong, nonatomic) NSMutableArray *handles;
//@interface BaseImageViewController : UIImageView
- (void)navigateToStoryboard:(NSString*)storyboardName;
- (IBAction)back:(id)sender;
- (IBAction)home:(id)sender;
- (IBAction)dismiss:(id)sender;
- (IBAction)modal:(id)sender;
- (IBAction)unwind:(UIStoryboardSegue*)sender;
- (IBAction)logout:(id)sender;
- (NSURL *)applicationDocumentsDirectory;
- (void)tearDownObservers;
- (BOOL)hasAccessToPost:(VTRPost*)post;
- (void)inviteToPost:(NSString*)postKey save:(BOOL)save;
@end

