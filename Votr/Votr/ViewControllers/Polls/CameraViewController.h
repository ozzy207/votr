//
//  CameraViewController.h
//  Votr
//
//  Created by Edward Kim on 1/15/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "LLSimpleCamera.h"

@interface CameraViewController : LLSimpleCamera
@property (nonatomic, copy) void (^contentCaptured)(NSURL *url,UIImage *image);
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL disableVideo;
@end
