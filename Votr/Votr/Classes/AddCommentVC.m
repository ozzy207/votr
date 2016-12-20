//
//  AddCommentVC.m
//  Votr
//
//  Created by tmaas510 on 20/12/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "AddCommentVC.h"
#import "CommentTableViewCell.h"
#import "DACircularProgressView.h"
#import "DALabeledCircularProgressView.h"

@interface AddCommentVC () <UITextFieldDelegate> {
    IBOutlet UILabel *titleLbl;
    IBOutlet UIImageView *avatarImg;
    IBOutlet UILabel *usernameLbl;
    IBOutlet UIView *firView;
    IBOutlet UIView *secView;
    IBOutlet UIImageView *firstImg;
    IBOutlet UIImageView *secondImg;
    
    IBOutlet UILabel *detailLbl1;
    IBOutlet UILabel *detailLbl2;
    IBOutlet DALabeledCircularProgressView *circular1;
    IBOutlet DALabeledCircularProgressView *circular2;
    
    IBOutlet UIButton *addCommentbtn;
    NSArray *commentAry;
    
    NSTimer *timer1;
    NSTimer *timer2;
    int p1, p2;
    
    IBOutlet UIView *inputView;
    IBOutlet UITextField *inputFld;
    IBOutlet NSLayoutConstraint *inputViewHeightConstraint;
    
}

@end

@implementation AddCommentVC
@synthesize obj;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Utils CustomiseViewWithoutBorder:addCommentbtn];
    [self initUIwithPollData];
    [self getComments];
    
    avatarImg.layer.cornerRadius = 10;
    avatarImg.layer.masksToBounds = YES;
    
    circular1.roundedCorners = YES;
    circular2.roundedCorners = YES;
}

-(void) initUIwithPollData {
    
    [obj fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            
            //display user info
            PFUser *user = obj[kPoster];
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if(!error){
                    usernameLbl.text = user.username;
                    PFFile *file = user[kAvatar];
                    if(file != nil){
                        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                            if(error== nil && data != nil){
                                avatarImg.image = [UIImage imageWithData:data];
                            }
                        }];
                    }
                }
            }];
            
            titleLbl.text = obj[kTitle];
            detailLbl1.text = obj[kTitle1];
            detailLbl2.text = obj[kTitle2];
            
            PFFile *file1 = obj[kThumb1];
            if(file1 != nil){
                [file1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if(error== nil && data != nil){
                        firstImg.image = [UIImage imageWithData:data];
                    }
                }];
            }
            
            PFFile *file2 = obj[kThumb2];
            if(file2 != nil){
                [file2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if(error== nil && data != nil){
                        secondImg.image = [UIImage imageWithData:data];
                    }
                }];
            }
            
            float n = [obj[kCountVote] floatValue];
            float n1 = [obj[kCountVote1] floatValue];
            p1 = (int)(n1 / n * 100);
            p2 = 100 - p1;
            NSLog(@"progress = %d, %d", p1, p2);
            if (p1 >= 50) {
                circular1.progressTintColor = tab_color;
                circular1.progressLabel.textColor = tab_color;
            }
            if (p2 >= 50) {
                circular2.progressTintColor = tab_color;
                circular2.progressLabel.textColor = tab_color;
            }
            
            [self startAnimation];
        }
    }];
}

- (void)startAnimation
{
    timer1 = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                  target:self
                                                selector:@selector(progressChange1)
                                                userInfo:nil
                                                 repeats:YES];
    timer2 = [NSTimer scheduledTimerWithTimeInterval:0.01
                                              target:self
                                            selector:@selector(progressChange2)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)progressChange1
{
    NSLog(@"circular1 = %d", (int)(circular1.progress * 100));
    if ([timer1 isValid] && (int)(circular1.progress * 100) < p1 - 1) {
        [circular1 setProgress:circular1.progress + 0.01f animated:YES];
    } else {
        [timer1 invalidate];
        timer1 = nil;
    }
    
    circular1.progressLabel.text = [NSString stringWithFormat:@"%.0f%%", circular1.progress * 100];
}

- (void)progressChange2
{
    if ([timer2 isValid] && (int)(circular2.progress * 100) < p2 - 1) {
        [circular2 setProgress:circular2.progress + 0.01f animated:YES];
    } else {
        [timer2 invalidate];
        timer2 = nil;
    }
    
    circular2.progressLabel.text = [NSString stringWithFormat:@"%.0f%%", circular2.progress * 100];
}

- (void)getComments {
    PFQuery *query = [PFQuery queryWithClassName:vClass_Comment];
    [query whereKey:@"poll" equalTo:obj];
    [query includeKey:@"user"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects != nil) {
            commentAry = objects;
            [self.tableView reloadData];
        } else {
            NSLog(@"Not found your comment!");
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)navBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addCommentAction:(id)sender {
    NSLog(@"Pending");
    [inputFld becomeFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        inputViewHeightConstraint.constant = self.view.bounds.size.height - 216 - 54;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)addButtonAction:(id)sender {
    int commentnum = [obj[kCountComment] intValue];
    commentnum = commentnum + 1;
    [ProgressHUD show:@"saving..." Interaction:NO];
    PFObject *obj2 = [PFObject objectWithClassName:vClass_Comment];
    obj2[kUser] = [PFUser currentUser];
    obj2[kPoll] = obj;
    obj2[kComment] = inputFld.text;
    obj2[kCountLike] = [NSNumber numberWithInt:0];
    [obj2 saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            [ProgressHUD dismiss];
            [Utils createAlert:msg_e_error withMessage:error.localizedDescription];
        }else{
            obj[kCountComment]  = [NSNumber numberWithInt:commentnum];
            [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [ProgressHUD dismiss];
                if(error){
                    
                    [Utils createAlert:msg_e_error withMessage:error.localizedDescription];
                }else{
                    [self saveObjectFinished];
                }
            }];
        }
    }];
}

- (void) saveObjectFinished {
    [inputFld resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        inputViewHeightConstraint.constant = -54.0f;
        [self.view layoutIfNeeded];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self saveObjectFinished];
    
    return YES;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName = [NSString stringWithFormat:@"%ld comments",(unsigned long)commentAry.count];
    
    return sectionName;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = [UIColor colorWithRed:.95 green:.95 blue:.95 alpha:1.0];
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:main_color];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return commentAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *idenfier = @"CommentCell";
    
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idenfier forIndexPath:indexPath];
    PFObject* obj1 = commentAry[indexPath.row];
    [obj1 fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            
            //display user info
            PFUser *user = obj1[kUser];
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if(!error){
                    cell.commentLbl.text = [NSString stringWithFormat:@"%@ | %@", user.username, obj1[kComment]];
                    PFFile *file = user[kAvatar];
                    if(file != nil){
                        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                            if(error== nil && data != nil){
                                cell.avatarImg.image = [UIImage imageWithData:data];
                            }
                        }];
                    }
                }
            }];
            
            cell.likeCountLbl.text = [NSString stringWithFormat:@"%@", obj1[kCountLike]];
        }
    }];
    
    
    return cell;
}

@end
