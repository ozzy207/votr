//
//  ProfileTableVC.m
//  Votr
//
//  Created by tmaas510 on 15/12/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "ProfileTableVC.h"

@interface ProfileTableVC () {

    IBOutlet UIImageView *avatarImg;
    IBOutlet UILabel *usernameLbl;
    IBOutlet UIButton *followBtn;
    IBOutlet UILabel *pollsLbl;
    IBOutlet UILabel *followingsLbl;
    IBOutlet UILabel *followersLbl;
    IBOutlet UIBarButtonItem *navSettingItem;
    PFUser *user;
    
    NSInteger type;
    NSMutableArray *pollAry;
    NSIndexPath *selectedIndexPath;
    
}

@end

@implementation ProfileTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [followBtn setHidden:YES];
    
    avatarImg.layer.cornerRadius = 40;
    avatarImg.layer.masksToBounds = YES;
    
    user = [PFUser currentUser];
    
    type = 1;
    pollAry = [[NSMutableArray alloc]init];
    
    [self initView];
}

-(void)initView {
    usernameLbl.text = user.username;
    PFFile *file = user[kAvatar];
    if(file != nil){
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if(error== nil && data != nil){
                avatarImg.image = [UIImage imageWithData:data];
            }
        }];
    }
    
    [self loadPolls:type];
}

- (IBAction)chooseCellType:(UIButton *)sender {
    type = sender.tag;
}

-(void)loadPolls:(NSInteger)tp {
    [ProgressHUD show:@"" Interaction:NO];
    if (tp == 1) {
        PFQuery *query = [PFQuery queryWithClassName:vClass_Poll];
        [query whereKey:kPoster equalTo:[PFUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [ProgressHUD dismiss];
            [pollAry addObjectsFromArray:objects];
            pollsLbl.text = [NSString stringWithFormat:@"%ld", pollAry.count];
            [self.tableView reloadData];
        }];
    } else {
        [pollAry removeAllObjects];
        [self.tableView reloadData];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return pollAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *idenfier = @"ProfileCell1";
    
    TimelineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idenfier forIndexPath:indexPath];
    
    PFObject* obj = pollAry[indexPath.row];
    [obj fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            
            //display user info
            cell.timeLbl.text = user.username;
            PFFile *file = user[kAvatar];
            if(file != nil){
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if(error== nil && data != nil){
                        cell.avatarImg.image = [UIImage imageWithData:data];
                    }
                }];
            }
            
            cell.titleLbl.text = obj[kTitle];
            cell.voteNumLbl.text = [NSString stringWithFormat:@"%@", obj[kCountVote]];
            cell.commentNumLbl.text = [NSString stringWithFormat:@"%@", obj[kCountComment]];
            
            NSDate *end = obj[kDateEnd];
            if ([Utils calculateTimeInterval:end] == NO) {
                [cell.alertImgView setHidden:YES];
            }
        }
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //get selected data from indexPath.row
    selectedIndexPath = indexPath;
    
    if (type == 1) {
        [self performSegueWithIdentifier:@"ResultstoCommentSegue" sender:self];
    } else {
        PFObject* obj = pollAry[indexPath.row];
        
        PFQuery *query = [PFQuery queryWithClassName:vClass_Vote];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        [query whereKey:@"poll" equalTo:obj];
        
        [ProgressHUD show:@"" Interaction:NO];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
            [ProgressHUD dismiss];
            if (object != nil) {
                NSLog(@"you already voted!");
                //go AddCommentVC
                [self performSegueWithIdentifier:@"ProfiletoCommentSegue" sender:self];
            }else{
                //go ChoosePollVC
                [self performSegueWithIdentifier:@"ProfileToVoteSegueID" sender:self];
            }
        }];
    }
    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ProfileToVoteSegueID"]) {
        UINavigationController *navvc = [segue destinationViewController];
        ChoosePollVC *vc = navvc.viewControllers.firstObject;
        vc.obj = pollAry[selectedIndexPath.row];
    } else if ([segue.identifier isEqualToString:@"ProfiletoCommentSegue"]) {
        AddCommentVC *vc = [segue destinationViewController];
        vc.obj = pollAry[selectedIndexPath.row];
    }
}

@end
