//
//  ResultsTableVC.m
//  Votr
//
//  Created by tmaas510 on 23/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "ResultsTableVC.h"
#import "CommentTableViewCell.h"

@interface ResultsTableVC () {

    IBOutlet UIView *headerView;
    
    IBOutlet UIImageView *pollImg1;
    IBOutlet UILabel *voteNum1;
    IBOutlet UILabel *popularityLbl1;
    
    IBOutlet UIImageView *pollImg2;
    IBOutlet UILabel *voteNum2;
    IBOutlet UILabel *popularityLbl2;
    
    IBOutlet UILabel *titleLbl1;
    IBOutlet UILabel *detailLbl1;
    IBOutlet UIButton *voteBtn1;
    IBOutlet UILabel *statsLbl1;
    
    IBOutlet UILabel *titleLbl2;
    IBOutlet UILabel *detailLbl2;
    IBOutlet UIButton *voteBtn2;
    IBOutlet UILabel *statsLbl2;
    
    IBOutlet UILabel *yourCommentLbl;
    IBOutlet UILabel *pollCloseLbl;
    IBOutlet UIView *pollCloseView;
    
    NSArray *commentAry;
    IBOutlet UINavigationItem *topBarItem;
    
}

@end

@implementation ResultsTableVC
@synthesize poll, isLoaded;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //get poll data
    if (isLoaded == YES) {
        [self initUI];
    } else {
        [self getLastPoll];
    }
}

-(void)getLastPoll {
    NSLog(@"getLastPoll");
}

- (void)initUI {
    NSLog(@"initUI");
    [self getYourComments];
    [self getComments];
    [self getYourVote];
    
    [poll fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            
            //display user info
            PFUser *user = poll[kPoster];
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if(!error){
                    NSString *creator = [NSString stringWithFormat:@"@%@_", user.username];
                    [self addAttributeStrToNavTitle:creator secStr:poll[kTitle]];
                }
            }];
            
            titleLbl1.text = poll[kTitle1];
            titleLbl2.text = poll[kTitle2];
            detailLbl1.text = poll[kDescribe1];
            detailLbl2.text = poll[kDescribe2];
            
            voteNum1.text = [NSString stringWithFormat:@"%@", poll[kCountVote1]];
            voteNum2.text = [NSString stringWithFormat:@"%@", poll[kCountVote2]];
            
            //popularity labels
            int n = [poll[kCountVote] intValue];
            int n1 = [poll[kCountVote1] intValue];
//            int n2 = [poll[kCountVote2] intValue];
            int p1 = (int) n1 / n * 100;
            int p2 = 100 - p1;
            popularityLbl1.text = [NSString stringWithFormat:@"Popularity:%d%% of votes", p1];
            popularityLbl2.text = [NSString stringWithFormat:@"Popularity:%d%% of votes", p2];
            
            pollCloseLbl.text = [Utils calculateTime:poll[kDateEnd]];
            
            PFFile *file1 = poll[kThumb1];
            if(file1 != nil){
                [file1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if(error== nil && data != nil){
                        pollImg1.image = [UIImage imageWithData:data];
                    }
                }];
            }
            
            PFFile *file2 = poll[kThumb2];
            if(file2 != nil){
                [file2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if(error== nil && data != nil){
                        pollImg2.image = [UIImage imageWithData:data];
                    }
                }];
            }
            
        }
    }];
}

-(void)getYourVote {
    PFQuery *query = [PFQuery queryWithClassName:vClass_Vote];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"poll" equalTo:poll];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object != nil) {
            if ([object[kVoted] isEqual:@1]) {
                [voteBtn1 setImage:[UIImage imageNamed:@"btn_check.png"] forState:UIControlStateNormal];
                statsLbl1.text = @"You voted for this one";
                [voteBtn2 setImage:[UIImage imageNamed:@"btn_retrack.png"] forState:UIControlStateNormal];
                statsLbl2.text = @"Retract";
            }else {
                [voteBtn2 setImage:[UIImage imageNamed:@"btn_check.png"] forState:UIControlStateNormal];
                statsLbl2.text = @"You voted for this one";
                [voteBtn1 setImage:[UIImage imageNamed:@"btn_retrack.png"] forState:UIControlStateNormal];
                statsLbl1.text = @"Retract";
            }
        } else {
            NSLog(@"Not found your comment!");
        }
    }];
}

- (void)getYourComments {
    PFQuery *query = [PFQuery queryWithClassName:vClass_Comment];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"poll" equalTo:poll];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object != nil) {
            yourCommentLbl.text = [NSString stringWithFormat:@"Your comment:%@", object[kComment]];
        } else {
            NSLog(@"Not found your comment!");
        }
    }];
}

- (void)getComments {
    PFQuery *query = [PFQuery queryWithClassName:vClass_Comment];
    [query whereKey:@"user" notEqualTo:[PFUser currentUser]];
    [query whereKey:@"poll" equalTo:poll];
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

-(void)addAttributeStrToNavTitle:(NSString*)fir secStr:(NSString*)sec {
    NSString *text = [NSString stringWithFormat:@"%@%@", fir, sec];
    /*
    UIColor *txtColor = [UIColor whiteColor];
    UIFont *generalFont = [UIFont systemFontOfSize:15];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:15];
    NSDictionary *attribs = @{NSForegroundColorAttributeName:txtColor, NSFontAttributeName:generalFont};
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]initWithString:text attributes:attribs];
    NSRange first = [text rangeOfString:fir];
    [attributedText setAttributes:@{NSForegroundColorAttributeName:txtColor, NSFontAttributeName:generalFont} range:first];
    NSRange second = [text rangeOfString:sec];
    [attributedText setAttributes:@{NSForegroundColorAttributeName:txtColor, NSFontAttributeName:boldFont} range:second]; */
    topBarItem.title = text;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGFloat h = pollCloseView.frame.origin.y;
    
    [UIView animateWithDuration:0.5f animations:^{
        headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, h + 50);
        [self.view layoutIfNeeded];
        [self.tableView reloadData];
    }];
    
}

- (IBAction)voteBtnClicked:(id)sender {
    //This action doesn't needed.
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
    PFObject* obj = commentAry[indexPath.row];
    [obj fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            
            //display user info
            PFUser *user = obj[kUser];
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if(!error){
                    NSString *creator = [NSString stringWithFormat:@"@%@: ", user.username];
                    [Utils addAttributeStr:cell.commentLbl withFirStr:creator secStr:obj[kComment]];
                    
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
            
            cell.likeCountLbl.text = [NSString stringWithFormat:@"%@", obj[kCountLike]];
        }
    }];
    
    
    return cell;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
