//
//  ResultsVC.m
//  Votr
//
//  Created by tmaas510 on 20/12/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "ResultsVC.h"

@interface ResultsVC () {
    IBOutlet UISegmentedControl *typeSegment;
    NSInteger type;
    NSMutableArray *pollAry;
    NSIndexPath *selectedIndexPath;
}

@end

@implementation ResultsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [typeSegment setTintColor:tab_color];
    type = 0;
    pollAry = [[NSMutableArray alloc]init];
    [self loadPolls:type];
}

-(void)loadPolls:(NSInteger)tp {
    [ProgressHUD show:@"" Interaction:NO];
    if (tp == 0) {
        PFQuery *query = [PFQuery queryWithClassName:vClass_Poll];
        [query whereKey:kPoster equalTo:[PFUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [ProgressHUD dismiss];
            [pollAry addObjectsFromArray:objects];
            [self.tableView reloadData];
        }];
    } else {
        PFQuery *query = [PFQuery queryWithClassName:vClass_Vote];
        [query whereKey:kUser equalTo:[PFUser currentUser]];
        [query includeKey:kPoll];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects != nil) {
                for (PFObject *obj in objects) {
                    PFObject *pollObj = obj[kPoll];
                    PFQuery *query = [PFQuery queryWithClassName:vClass_Poll];
                    [query getObjectInBackgroundWithId:pollObj.objectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
                        [ProgressHUD dismiss];
                        if (object != nil) {
                            [pollAry addObject:object];
                            [self.tableView reloadData];
                        }
                        
                    }];
                }

            } else {
                [self.tableView reloadData];
            }
        }];

    }
    
}

- (IBAction)publicSegmentChanged:(UISegmentedControl *)sender {
    //This method is not used for now.
    type = sender.selectedSegmentIndex;
    [pollAry removeAllObjects];
    [self loadPolls:type];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return pollAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *idenfier = @"ResultCell";
    
    TimelineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idenfier forIndexPath:indexPath];
    
    PFObject* obj = pollAry[indexPath.row];
    [obj fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            
            //display user info
            PFUser *user = obj[kPoster];
            
            
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if(!error){
                    cell.timeLbl.text = user.username;
                    //set poll type
                    if ([user.username isEqual:[PFUser currentUser].username]) {
                        NSLog(@"you created");
                        cell.pollTyleView.backgroundColor = vBlue_color;
                    } else {
                        PFQuery *query = [PFQuery queryWithClassName:vClass_Vote];
                        [query whereKey:@"user" equalTo:[PFUser currentUser]];
                        [query whereKey:@"poll" equalTo:obj];
                        
                        [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                            [ProgressHUD dismiss];
                            if (object != nil) {
                                NSLog(@"you already voted!");
                                cell.pollTyleView.backgroundColor = [UIColor lightGrayColor];
                            }else{
                                cell.pollTyleView.backgroundColor = tab_color;
                            }
                        }];
                    }
                    
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
                [self performSegueWithIdentifier:@"ResultstoCommentSegue" sender:self];
            }else{
                //go ChoosePollVC
                [self performSegueWithIdentifier:@"ResultsToVoteSegueID" sender:self];
            }
        }];
    }
    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ResultsToVoteSegueID"]) {
        UINavigationController *navvc = [segue destinationViewController];
        ChoosePollVC *vc = navvc.viewControllers.firstObject;
        vc.obj = pollAry[selectedIndexPath.row];
    } else if ([segue.identifier isEqualToString:@"ResultstoCommentSegue"]) {
        AddCommentVC *vc = [segue destinationViewController];
        vc.obj = pollAry[selectedIndexPath.row];
    }
}

@end
