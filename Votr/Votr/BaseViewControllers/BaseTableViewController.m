//
//  BaseTableViewController.m
//
//  Created by Edward Kim on 10/18/16.
//  Copyright © 2016 DedStop. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()
@property (strong, nonatomic) NSMutableDictionary *rowHeights;
@end

@implementation BaseTableViewController

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self home:nil];
	
	[self.tableView setRowHeight:UITableViewAutomaticDimension];
	[self.tableView setEstimatedRowHeight:45];
	
	self.rowHeights = [NSMutableDictionary	new];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sizeHeaderToFit
{
	//set the tableHeaderView so that the required height can be determined
	UIView *header = self.tableView.tableHeaderView;
	[header setNeedsLayout];
	[header layoutIfNeeded];
	CGFloat height = [header systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
	
	//update the header's frame and set it again
	CGRect headerFrame = header.frame;
	headerFrame.size.height = height;
	header.frame = headerFrame;
	self.tableView.tableHeaderView = header;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableView Datasource
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.rowHeights[indexPath] = @(cell.frame.size.height);
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.rowHeights[indexPath]? [self.rowHeights[indexPath] floatValue]:45;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

	static NSString *identifier = @"default"; //added
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
   //We don't really need the cell == nil. I personally keep this out to have the app crash to remind me that i always need to have a prototype cell in the storyboard. If I do add the cell == nil part then the app won't crash and create a prototype cell for me...
        if (cell == nil) {  //added
		//we can't use default here. Notice your static variable has a capital D and xcode is case sensitive so it won't find it. Also lowercase default is a name already taken by Apple.
		 //For a base class I would remove this line since we won't have any data and would cause a crash.
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ; //added
        }
        [cell.textLabel setText: [_data objectAtIndex:indexPath.row]]; //added
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

         
-(IBAction)addVehicle:(id)sender //added
{
	[_data addObject:@"Vehicle"];
	NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_data count]-1 inSection:1]];
	[[self tableView] insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
}

@end
