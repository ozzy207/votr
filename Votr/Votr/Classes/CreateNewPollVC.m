//
//  CreateNewPollVC.m
//  Votr
//
//  Created by tmaas510 on 19/12/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "CreateNewPollVC.h"
#import "ASJTagsView.h"
#import "SCLAlertView.h"
#import "ViewPollVC.h"

@interface CreateNewPollVC () <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate>{

    IBOutlet UISegmentedControl *publicSegment;
    IBOutlet UITextField *titleLbl;
    IBOutlet UIImageView *choiceImg1;
    IBOutlet UIImageView *choiceImg2;
    IBOutlet UITextField *choiceTitleLbl1;
    IBOutlet UITextField *choiceTitleLbl2;
    IBOutlet UITextField *tagFld;
    IBOutlet UIButton *postBtn;
    
    IBOutlet UIButton *plusBtn1;
    IBOutlet UIButton *plusBtn2;

    NSInteger selectedChoice;
    UIToolbar *m_toolBar;
    NSString *placeholdTxt1;
    NSString *placeholdTxt2;
    UIDatePicker *datePicker;
    UITextField *currentTextField;
    
    NSMutableDictionary * dict;
    NSMutableArray *tags;
    NSDate *start, *end;
    
    IBOutlet UITextField *startFld;
    IBOutlet UITextField *endFld;
    IBOutlet UIView *starttimeView;
}
@property (weak, nonatomic) IBOutlet ASJTagsView *tagsView;
@end

@implementation CreateNewPollVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [publicSegment setTintColor:tab_color];
    
    selectedChoice = 0;
    startFld.placeholder = @"Delayed";
    endFld.placeholder = [Utils dateToString:[NSDate date] format:@"EEE, MMM dd, yyyy" timezone:@"UTC"];
    
    [self addDoneButton];
    [self createDatePicker];
    
    //tag view
    _tagsView.tagColorTheme = TagColorThemeIndigo;
    [self handleTagBlocks];
    
    tags = [[NSMutableArray alloc]init];
    start = [NSDate date];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)addDoneButton {
    m_toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [m_toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(btnDoneClick:)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    m_toolBar.items = [[NSArray alloc] initWithObjects:flexibleItem, barButtonDone, nil];
    barButtonDone.tintColor = [UIColor blackColor];
    tagFld.inputAccessoryView = m_toolBar;
}

- (void)btnDoneClick:(id)sender{
    [currentTextField resignFirstResponder];
}

-(void)createDatePicker {
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    [datePicker addTarget:self action:@selector(onDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
}

-(void)onDatePickerValueChanged:(id)sender {
    NSDate *date = datePicker.date;
    NSLog(@"end = %@", date);
    NSString *dateStr = [Utils dateToString:date format:@"EEE, MMM dd, yyyy" timezone:@"Local"];
    currentTextField.text = dateStr;
    
    if ([currentTextField isEqual:startFld]) {
        start = datePicker.date;
    } else {
        end = datePicker.date;
    }
}

- (IBAction)addStartEndTimeAction:(id)sender {
    [starttimeView removeFromSuperview];
}

#pragma mark - TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:tagFld]) {
        [self addTagsAction:textField.text];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    currentTextField = textField;
    if ([textField isEqual:startFld] || [textField isEqual:endFld]) {
        textField.inputView = datePicker;
        textField.inputAccessoryView = m_toolBar;
    }
    
    if ([textField isEqual:tagFld]) {
        textField.inputAccessoryView = m_toolBar;
    }
    
    return YES;
}

-(void)addTagsAction:(NSString*)text {
    [_tagsView addTag:text];
    tagFld.text = nil;
    [tags addObject:text];
}

- (void)handleTagBlocks
{
    __weak typeof(self) weakSelf = self;
    [_tagsView setDeleteBlock:^(NSString *tagText, NSInteger idx)
     {
         [tags removeObjectAtIndex:idx];
         [weakSelf.tagsView deleteTagAtIndex:idx];
     }];
}

#pragma mark - Thumbnails Methods

- (IBAction)publicSegmentChanged:(UISegmentedControl *)sender {
    //This method is not used for now.
    NSString *title = [publicSegment titleForSegmentAtIndex:publicSegment.selectedSegmentIndex];
    NSLog(@"public or private = %@", title);
}

- (IBAction)tapImageAction1:(id)sender {
    selectedChoice = 1;
    [self addImageDescribe:selectedChoice];
}

- (IBAction)tapImageAction2:(id)sender {
    selectedChoice = 2;
    [self addImageDescribe:selectedChoice];
}

- (void)addImageDescribe:(NSInteger)index {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
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
                                    actionWithTitle:@"Choose photo from library"
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
    [alert addAction:cameraButton];
    [alert addAction:galleryButton];
    [alert addAction:cancelButton];
    
    if (selectedChoice == 1) {
        alert.popoverPresentationController.sourceView = choiceImg1;
        alert.popoverPresentationController.sourceRect = CGRectMake(choiceImg1.bounds.size.width / 2, choiceImg1.bounds.size.height / 2, 1.0, 1.0);
    } else {
        alert.popoverPresentationController.sourceView = choiceImg2;
        alert.popoverPresentationController.sourceRect = CGRectMake(choiceImg2.bounds.size.width / 2, choiceImg2.bounds.size.height / 2, 1.0, 1.0);
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Image Picker Controller delegate methods

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImg = info[UIImagePickerControllerEditedImage];
    
    CGSize newSize = CGSizeMake(300, 300);
    if (selectedChoice == 1) {
        choiceImg1.image = [self imageWithImage:chosenImg scaledToSize:newSize];
        [plusBtn1 setHidden:YES];
    } else {
        choiceImg2.image = [self imageWithImage:chosenImg scaledToSize:newSize];
        [plusBtn2 removeFromSuperview];
    }
    
    [picker dismissViewControllerAnimated:YES completion:Nil];
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

#pragma mark - Post Action

- (IBAction)postAction:(id)sender {
//    [self showSuccessAlert];
    //*
    PFObject *obj = [PFObject objectWithClassName:vClass_Poll];
    obj[kPoster] = [PFUser currentUser];
    obj[kTitle] = titleLbl.text;
    obj[kPosttype] = [publicSegment titleForSegmentAtIndex:publicSegment.selectedSegmentIndex];
    obj[kType] = [NSNumber numberWithInteger:1];
    obj[kTitle1] = choiceTitleLbl1.text;
    obj[kTitle2] = choiceTitleLbl2.text;
    obj[kDateStart] = start;
    obj[kDateEnd] = end;
    obj[kTags] = tags;
    obj[kDatePost] = [NSDate date];
    obj[kThumb1] = [self getPFFileFromImage:choiceImg1.image];
    obj[kThumb2] = [self getPFFileFromImage:choiceImg2.image];
    obj[kCountVote] = [NSNumber numberWithInt:0];
    obj[kCountVote1] = [NSNumber numberWithInt:0];
    obj[kCountVote2] = [NSNumber numberWithInt:0];
    obj[kCountComment] = [NSNumber numberWithInt:0];
    
    [ProgressHUD show:@"uploading..." Interaction:NO];
    [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [ProgressHUD dismiss];
        if(error){
            [Utils createAlert:msg_e_error withMessage:error.localizedDescription];
        }else{
            [self showSuccessAlert];
        }
    }]; //*/
}

-(void)showSuccessAlert {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    
    [alert addButton:@"Invite Friends" actionBlock:^(void) {
        [ProgressHUD show:@"Pending" Interaction:YES];
    }];
    
    [alert addButton:@"View Poll" actionBlock:^(void) {
        dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                titleLbl.text, kTitle,
                choiceImg1.image, kThumb1,
                choiceImg2.image, kThumb2,
                choiceTitleLbl1.text, kTitle1,
                choiceTitleLbl2.text, kTitle2, nil];
        [self performSegueWithIdentifier:@"toViewPollSegue" sender:self];
    }];
    
    [alert showSuccess:@"Posted Successfully!" subTitle:@"" closeButtonTitle:@"Done" duration:0.0f];
}

- (PFFile*)getPFFileFromImage: (UIImage *)image {
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    return [PFFile fileWithData:data];
}

- (IBAction)navBackAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toViewPollSegue"]) {
        ViewPollVC *vc = [segue destinationViewController];
        NSLog(@"dict = %@", dict);
        vc.poll = [[Poll alloc] initWithDict:dict];
    }
}

@end
