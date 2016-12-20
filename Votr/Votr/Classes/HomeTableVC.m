//
//  HomeTableVC.m
//  Votr
//
//  Created by tmaas510 on 23/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "HomeTableVC.h"
#import "VoteTableVC.h"

@interface HomeTableVC () <UISearchBarDelegate> {

    IBOutlet UISearchBar *searchbar;
    NSDate *dateTop;
    NSDate *dateBottom;
    NSUInteger lastIndex;
    NSIndexPath *selectedIndexPath;
    
    NSMutableArray *pollAry;
}

@end

@implementation HomeTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    searchbar.layer.borderWidth = 1;
    searchbar.layer.borderColor = [bg_color CGColor];
    
    lastIndex = 0;
    
    // add refresh control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshPolls:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    //init array and date
    pollAry = [[NSMutableArray alloc]init];
    dateBottom = [NSDate date];
    dateTop = [NSDate date];
    
    [self loadPolls];
    
}

- (void)loadPolls {
    NSLog(@"load polls...");
    
    PFQuery *query = [PFQuery queryWithClassName:vClass_Poll];
    query.limit = 20;
    [query whereKey:@"createdAt" lessThan:dateBottom];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [pollAry addObjectsFromArray:objects];
        
        PFObject *obj = pollAry.lastObject;
        dateBottom = obj.createdAt;
        
        [self.tableView reloadData];
    }];
}

- (void)refreshPolls:(UIRefreshControl *)refreshControl{
    NSLog(@"refresh polls...");
    
    //refreash polls
    PFQuery *query = [PFQuery queryWithClassName:vClass_Poll];
    query.limit = 20;
    [query whereKey:@"createdAt" greaterThan:dateTop];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error && (objects.count > 0)){
            [pollAry insertObjects:objects atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, objects.count)]];
            [refreshControl endRefreshing];
            PFObject *obj = pollAry.firstObject;
            dateTop = obj.createdAt;
            
            [self.tableView reloadData];
        }else{
            [refreshControl endRefreshing];
        }
    }];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)newPollAction:(id)sender {
    [self performSegueWithIdentifier:@"topollSegue" sender:self];
}

#pragma mark - Search Bar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = true;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //TODO
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel clicked");
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = false;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = false;
    
    //TODO reload data and tableview
    // [self.tblContentList reloadData];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%ld row cell display", (long)indexPath.row);
    
    if((indexPath.row == pollAry.count - 1) && (lastIndex!=indexPath.row) && indexPath.row >= 9){
        lastIndex = indexPath.row;
        [self loadPolls];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return pollAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *idenfier = @"HomeCell";

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
            [self performSegueWithIdentifier:@"HometoCommentSegue" sender:self];
        }else{
            //go ChoosePollVC
            [self performSegueWithIdentifier:@"goHomeToVoteSegueID" sender:self];
        }
    }];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goHomeToVoteSegueID"]) {
        UINavigationController *navvc = [segue destinationViewController];
        ChoosePollVC *vc = navvc.viewControllers.firstObject;
        vc.obj = pollAry[selectedIndexPath.row];
    } else if ([segue.identifier isEqualToString:@"HometoCommentSegue"]) {
        AddCommentVC *vc = [segue destinationViewController];
        vc.obj = pollAry[selectedIndexPath.row];
    }
}


@end
