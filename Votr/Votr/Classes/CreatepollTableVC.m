//
//  CreatepollTableVC.m
//  Votr
//
//  Created by tmaas510 on 30/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "CreatepollTableVC.h"
#import "PostPollTableVC.h"
#import "ASJTagsView.h"

@interface CreatepollTableVC () <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate>{

    IBOutlet UISwitch *isVoteSwitch;
    IBOutlet UITextField *titleFld;
    IBOutlet UIView *tagView;
    IBOutlet UITextField *tagFld;
    IBOutlet UITextField *startFld;
    IBOutlet UITextField *endFld;
    
    IBOutlet UIView *detailsView;
    IBOutlet UIImageView *choiceImg1;
    IBOutlet UIImageView *choiceImg2;
    IBOutlet UIView *addSecView;
    IBOutlet UIView *addFstView;
    
    IBOutlet UITextField *choiceTitleLbl1;
    IBOutlet UITextView *choiceDescribeTxtView1;
    IBOutlet UITextField *choiceTitleLbl2;
    IBOutlet UITextView *choiceDescribeTxtView2;
    
    NSInteger selectedChoice;
    UIToolbar *m_toolBar;
    NSString *placeholdTxt1;
    NSString *placeholdTxt2;
    UIDatePicker *datePicker;
    UITextField *currentTextField;
    
    NSMutableDictionary * dict;
    NSMutableArray *tags;
    NSDate *start, *end;
}

@property (weak, nonatomic) IBOutlet ASJTagsView *tagsView;

@end

@implementation CreatepollTableVC

- (void)viewDidLoad {
    [super viewDidLoad];

    selectedChoice = 1;
    placeholdTxt1 = @"Choice 1 description(140 characters maximum):";
    placeholdTxt2 = @"Choice 2 description(140 characters maximum):";
    
    startFld.placeholder = [Utils dateToString:[NSDate date] format:@"EEE, MMM dd, yyyy" timezone:@"UTC"];
    startFld.placeholder = @"Delayed";
    endFld.placeholder = [Utils dateToString:[NSDate date] format:@"EEE, MMM dd, yyyy" timezone:@"UTC"];
    
    //add inputAccessoryView to Keyboard when show keyboard for UITextView
    [self addDoneButton];
    
    [self createDatePicker];
    
    //tag view
    _tagsView.tagColorTheme = TagColorThemeIndigo;
    [self handleTagBlocks];
    
    tags = [[NSMutableArray alloc]init];
    start = [NSDate date];
}

-(void)addDoneButton {
    m_toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    [m_toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(btnDoneClick:)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    m_toolBar.items = [[NSArray alloc] initWithObjects:flexibleItem, barButtonDone, nil];
    barButtonDone.tintColor = [UIColor blackColor];
    choiceDescribeTxtView1.inputAccessoryView = m_toolBar;
}

- (void)btnDoneClick:(id)sender{
    [choiceDescribeTxtView1 resignFirstResponder];
    [choiceDescribeTxtView2 resignFirstResponder];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - TextView Delegate Methods

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([textView isEqual: choiceDescribeTxtView1]) {
        choiceDescribeTxtView1.inputAccessoryView = m_toolBar;
    } else {
        choiceDescribeTxtView2.inputAccessoryView = m_toolBar;
    }
    
    return YES;
}

- (void) textViewDidBeginEditing:(UITextView *) textView {
    if ([textView.text isEqualToString:placeholdTxt1] || [textView.text isEqualToString:placeholdTxt2]) {
        textView.text = @"";
    }
}

-(void) textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""] && [textView isEqual: choiceDescribeTxtView1]) {
        textView.text = placeholdTxt1;
    }
    if ([textView.text isEqualToString:@""] && [textView isEqual: choiceDescribeTxtView2]) {
        textView.text = placeholdTxt2;
    }
}

#pragma mark - Post Action

- (IBAction)postAction:(id)sender {
    if ([titleFld.text  isEqual: @""] || [choiceTitleLbl1.text  isEqual: @""] || [choiceTitleLbl2.text  isEqual: @""] || [startFld.text  isEqual: @""] || [endFld.text  isEqual: @""]) {
        [ProgressHUD showError:msg_e_fillAll];
        return;
    }
    
     dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
              titleFld.text, kTitle,
              choiceImg1.image, kThumb1,
              choiceImg2.image, kThumb2,
              choiceTitleLbl1.text, kTitle1,
              choiceTitleLbl2.text, kTitle2,
              choiceDescribeTxtView1.text, kDescribe1,
              choiceDescribeTxtView2.text, kDescribe2,
              start, kDateStart,
              end, kDateEnd,
              [NSNumber numberWithInteger:1], kType,
              tags, kTags, nil];

    [self performSegueWithIdentifier:@"goConfirmPollSegue" sender:self];
}

- (IBAction)voteIncognitoSwitchChanged:(UISwitch *)sender {
    
}

//Photo, Video, Text buttons Action(tag:1~3)
- (IBAction)pollModeBtnsAction:(UIButton *)sender {
    selectedChoice = 1;
    [self addImageDescribe:selectedChoice];
}

- (IBAction)addFstBtnAction:(id)sender {
    selectedChoice = 1;
    [self addImageDescribe:selectedChoice];
}

- (IBAction)addSecBtnAction:(id)sender {
    selectedChoice = 2;
    [self addImageDescribe:selectedChoice];
}

- (IBAction)tapChoiceImg1:(UITapGestureRecognizer *)sender {
    selectedChoice = 1;
    [self addImageDescribe:selectedChoice];
}

- (IBAction)tapChoiceImg2:(UITapGestureRecognizer *)sender {
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
        [addFstView setHidden:YES];
    } else {
        choiceImg2.image = [self imageWithImage:chosenImg scaledToSize:newSize];
        [addSecView setHidden:YES];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"goConfirmPollSegue"]) {
        PostPollTableVC *vc = [segue destinationViewController];
        NSLog(@"dict = %@", dict);
        vc.poll = [[Poll alloc] initWithDict:dict];
    }
}


@end
