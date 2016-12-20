//
//  PostPollTableVC.m
//  Votr
//
//  Created by tmaas510 on 30/09/16.
//  Copyright © 2016 Thomas Maas. All rights reserved.
//

#import "PostPollTableVC.h"

@interface PostPollTableVC () {

    IBOutlet UILabel *nameLbl;
    IBOutlet UILabel *publicPolllbl;
    
    IBOutlet UIImageView *candidateImg1;
    IBOutlet UIImageView *candidateImg2;
    
    IBOutlet UILabel *titleLbl1;
    IBOutlet UILabel *describeLbl1;
    IBOutlet UILabel *titleLbl2;
    IBOutlet UILabel *descibeLbl2;
    
    IBOutlet UILabel *startDateLbl;
    IBOutlet UILabel *endDateLbl;
    PFUser *user;
}

@end

@implementation PostPollTableVC
@synthesize poll;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    user = [PFUser currentUser];
    [self updateUI];
}

-(void)updateUI {
    
    [Utils addAttributeStr:nameLbl withFirStr:[NSString stringWithFormat:@"@%@: ", user.username] secStr:poll.title];
    titleLbl1.text = poll.candiTitle1;
    titleLbl2.text = poll.candiTitle2;
//    describeLbl1.text = poll.candiDescr1;
//    descibeLbl2.text = poll.candiDescr2;
    
//    NSString *startStr = [Utils dateToString:poll.startDate format:@"EEE, MMM dd, yyyy" timezone:@"Local"];
//    NSString *endStr = [Utils dateToString:poll.endDate format:@"EEE, MMM dd, yyyy" timezone:@"Local"];
    
//    startDateLbl.text = [NSString stringWithFormat:@"Starts:  %@", startStr];
//    endDateLbl.text = [NSString stringWithFormat:@"Ends:      %@", endStr];
    candidateImg1.image = poll.candiThum1;
    candidateImg2.image = poll.candiThum2;
    
//    if ([poll.voteIncognito isEqual:@0]) {
//        publicPolllbl.text = @"Private Poll";
//    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Post Action

- (IBAction)editBtnAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)postAction:(id)sender {
    PFObject *obj = [PFObject objectWithClassName:vClass_Poll];
    obj[kPoster] = [PFUser currentUser];
    obj[kTitle] = poll.title;
//    obj[kType] = poll.pollType;
    obj[kTitle1] = poll.candiTitle1;
//    obj[kDescribe1] = poll.candiDescr1;
    obj[kTitle2] = poll.candiTitle2;
//    obj[kDescribe2] = poll.candiDescr2;
//    obj[kDateStart] = poll.startDate;
//    obj[kDateEnd] = poll.endDate;
//    obj[kTags] = poll.tagAry;
    obj[kDatePost] = [NSDate date];
    obj[kThumb1] = [self getPFFileFromImage:poll.candiThum1];
    obj[kThumb2] = [self getPFFileFromImage:poll.candiThum2];
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
            [ProgressHUD showSuccess:@"Success!"];
            //go HomeVC
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
    
}

- (IBAction)inviteFriendsSwitchChanged:(UISwitch *)sender {
    [ProgressHUD showError:@"Pending!"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (PFFile*)getPFFileFromImage: (UIImage *)image {
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    return [PFFile fileWithData:data];
}

@end
