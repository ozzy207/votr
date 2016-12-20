//
//  PopularTableVC.m
//  Votr
//
//  Created by tmaas510 on 23/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "PopularTableVC.h"
#import "VoteTableVC.h"
@interface PopularTableVC () {
    
    NSMutableArray *privateAry;
    NSMutableArray *publicAry;
    int allLoaded;
    PFObject *selectedObj;
}

@end

@implementation PopularTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    privateAry = [[NSMutableArray alloc]init];
    publicAry = [[NSMutableArray alloc]init];
    allLoaded = 0;
    [self loadPolls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadPolls {
    NSLog(@"load polls...");
    
    [ProgressHUD show:@"" Interaction:NO];
    PFQuery *query = [PFQuery queryWithClassName:vClass_Poll];
    [query whereKey:kPosttype equalTo:@"Private Poll"];
    [query whereKey:kPoster notEqualTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [privateAry addObjectsFromArray:objects];
        NSLog(@"private polls = %ld", privateAry.count);
        allLoaded += 1;
        [self checkreloadTableView];
    }];
    
    PFQuery *query2 = [PFQuery queryWithClassName:vClass_Poll];
    [query2 whereKey:kPosttype equalTo:@"Public Poll"];
    [query2 whereKey:kPoster notEqualTo:[PFUser currentUser]];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [publicAry addObjectsFromArray:objects];
        NSLog(@"public polls = %ld", publicAry.count);
        allLoaded += 1;
        [self checkreloadTableView];
    }];
}

-(void)checkreloadTableView {
    if (allLoaded == 2) {
        [ProgressHUD dismiss];
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"PRIVATE POLL";
            break;
        case 1:
            sectionName = @"PUBLIC POLL";
            break;
            // ...
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    view.tintColor = bg_color;
    
    // Text Color
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor darkGrayColor]];
    [header.textLabel setFont:[UIFont systemFontOfSize:15.f]];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //TODO get section number
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return privateAry.count;
    } else {
        return publicAry.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *idenfier = @"PopularCell";
    
    TimelineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idenfier forIndexPath:indexPath];
    
    NSArray * pollAry;
    if (indexPath.section == 0) {
        pollAry = privateAry;
    } else {
        pollAry = publicAry;
    }
    PFObject* obj = pollAry[indexPath.row];
    [obj fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            
            //display user info
            PFUser *user = obj[kPoster];
            
            
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if(!error){
                    cell.timeLbl.text = user.username;
                    //set poll type
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
    
    NSArray * pollAry;
    if (indexPath.section == 0) {
        pollAry = privateAry;
    } else {
        pollAry = publicAry;
    }
    
    PFObject* obj = pollAry[indexPath.row];
    selectedObj = obj;
    
    PFQuery *query = [PFQuery queryWithClassName:vClass_Vote];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"poll" equalTo:obj];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [ProgressHUD dismiss];
        if (object != nil) {
            NSLog(@"you already voted!");
            //go AddCommentVC
            [self performSegueWithIdentifier:@"populartoCommentSegue" sender:self];
        }else{
            //go ChoosePollVC
            [self performSegueWithIdentifier:@"popularToVoteSegueID" sender:self];
        }
    }];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 28)];
    [headerView setBackgroundColor:[UIColor colorWithRed:.95 green:.95 blue:.95 alpha:1.0]];
    return headerView;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"popularToVoteSegueID"]) {
        UINavigationController *navvc = [segue destinationViewController];
        ChoosePollVC *vc = navvc.viewControllers.firstObject;
        vc.obj = selectedObj;
    } else if ([segue.identifier isEqualToString:@"populartoCommentSegue"]) {
        AddCommentVC *vc = [segue destinationViewController];
        vc.obj = selectedObj;
    }
}


@end
