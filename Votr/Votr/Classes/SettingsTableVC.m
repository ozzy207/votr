//
//  SettingsTableVC.m
//  Votr
//
//  Created by tmaas510 on 23/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "SettingsTableVC.h"

@interface SettingsTableVC () <UITextFieldDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate> {

    IBOutlet UIImageView *avatarImg;
    IBOutlet UITextField *usernameFld;
    
    PFUser *user;
}

@end

@implementation SettingsTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    avatarImg.layer.cornerRadius = 31;
    avatarImg.layer.masksToBounds = YES;
    
    [self initView];
}

-(void)initView {
    
    user = [ PFUser currentUser];
    usernameFld.text = user.username;
    PFFile *file = user[kAvatar];
    if(file != nil){
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if(error== nil && data != nil){
                avatarImg.image = [UIImage imageWithData:data];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    [self updateUsername:textField.text];
    return YES;
}

- (void)updateUsername:(NSString*)text {
    
    [ProgressHUD show:@"" Interaction:NO];
    user.username = text;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [ProgressHUD dismiss];
        if(error){
            NSString *errorString = [error userInfo][@"error"];
            [Utils createAlert:@"Error" withMessage:errorString];
        }
    }];
}

- (IBAction)navCancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)navDoneAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editTopicsAction:(id)sender {
    //Pending
}

- (IBAction)logoutAction:(id)sender {
    //logout current user
    [PFUser logOut];
    
    //go firstVC
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *vc = [storyboard instantiateViewControllerWithIdentifier:@"FirstVC"];
    AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
    del.window.rootViewController = vc;
}

// Change Avatar
- (IBAction)changeAvatarAction:(id)sender {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Change Avatar"
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* removeButton = [UIAlertAction
                                   actionWithTitle:@"Remove Current Photo"
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction * action)
                                   {
                                       UIImage *image = nil;
                                       [self uploadAvatarImage:image];
                                   }];
    UIAlertAction* cameraButton = [UIAlertAction
                                   actionWithTitle:@"Take a photo"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                       picker.delegate = self;
                                       picker.allowsEditing = YES;
#if TARGET_IPHONE_SIMULATOR
                                       picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#else
                                       picker.sourceType = UIImagePickerControllerSourceTypeCamera;
#endif
                                       if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
                                       {
                                           [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                               // Place image picker on the screen
                                               [self presentViewController:picker animated:YES completion:NULL];
                                           }];
                                       }
                                       else
                                       {
                                           [self presentViewController:picker animated:YES completion:NULL];
                                       }
                                   }];
    UIAlertAction* galleryButton = [UIAlertAction
                                    actionWithTitle:@"Choose from Library"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                        picker.delegate = self;
                                        picker.allowsEditing = YES;
                                        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                        
                                        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
                                        {
                                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                // Place image picker on the screen
                                                [self presentViewController:picker animated:YES completion:NULL];
                                            }];
                                        }
                                        else
                                        {
                                            [self presentViewController:picker animated:YES completion:NULL];
                                        }
                                    }];
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action)
                                   {
                                       
                                   }];
    [alert addAction:removeButton];
    [alert addAction:cameraButton];
    [alert addAction:galleryButton];
    [alert addAction:cancelButton];
    
    alert.popoverPresentationController.sourceView = self.tableView;
    alert.popoverPresentationController.sourceRect = CGRectMake(self.tableView.bounds.size.width - 50, 50, 1.0, 1.0);
    alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)uploadAvatarImage:(UIImage *)image {
    [ProgressHUD show:@"" Interaction:NO];
    user[kAvatar] = [self getPFFileFromImage:image];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [ProgressHUD dismiss];
        if(succeeded == YES && !error){
            [ProgressHUD showSuccess:@"Successfully updated!"];
            avatarImg.image = image;
            
        }else{
            NSString *errorString = [error userInfo][@"error"];
            [Utils createAlert:@"Error" withMessage:errorString];
        }
    }];
}

- (PFFile*)getPFFileFromImage: (UIImage *)image {
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    return [PFFile fileWithData:data];
}


#pragma mark - Image Picker Controller delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *chosenImg = info[UIImagePickerControllerEditedImage];
    
    CGSize newSize = CGSizeMake(100, 100);
    UIImage *image = [self imageWithImage:chosenImg scaledToSize:newSize];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self uploadAvatarImage:image];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:Nil];
}

- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
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
