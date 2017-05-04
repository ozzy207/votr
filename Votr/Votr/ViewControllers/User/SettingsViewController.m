//
//  SettingsViewController.m
//  Votr
//
//  Created by Edward Kim on 2/26/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIImageView+WebCache.h"
#import "BRAlertView.h"
#import "AuthTopicViewController.h"
#import "BRFloatTextView.h"	
#import "BRImageView.h"
#import "CameraViewController.h"

@interface SettingsViewController ()<UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet BRImageView *detailImageView1;
@property (strong, nonatomic) BRFloatTextView *floatView;
@property (strong, nonatomic) UIImagePickerController *picker1;
@end

@implementation SettingsViewController

#pragma mark - Life Cycle
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self tearDownObservers];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.tableView setSectionHeaderHeight:44];
	
	FIRDatabaseReference *ref = [[[[DataManager sharedInstance] refDatabase] child:@"users"] child:[FIRAuth auth].currentUser.uid];
	
	FIRDatabaseHandle handle = [ref observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
		if ([snapshot.key isEqualToString:@"displayName"]) {
			self.data = [@[@[snapshot.value],@[@"Change Password",@"Edit my topics"],@[@"Logout"]] mutableCopy];
			[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		}
	
		if ([snapshot.key isEqualToString:@"photoURL"]) {
			UIImage *placeholderImage = [UIImage imageNamed:@"default_avatar"];
			[self.detailImageView1	sd_setImageWithURL:snapshot.value placeholderImage:placeholderImage];
		}
	}];
	
	[self.handles addObject:[VTRHandle handle:handle withRef:ref]];
	
	self.data = [@[@[[DataManager sharedInstance].user.displayName],@[@"Change Password",@"Edit my topics"],@[@"Logout"]] mutableCopy];
	[self.tableView setTableFooterView:[UIView new]];
	
	UIImage *placeholderImage = [UIImage imageNamed:@"default_avatar"];
	// Load the image using SDWebImage
	[self.detailImageView1	sd_setImageWithURL:[DataManager sharedInstance].user.photoURL placeholderImage:placeholderImage];
	
	self.picker1 = [[UIImagePickerController alloc] init];
	self.picker1.allowsEditing = YES;
	self.picker1.delegate = self;
	self.picker1.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
	if ([segue.identifier isEqualToString:@"Topics"]) {
		AuthTopicViewController *controller = [[segue.destinationViewController childViewControllers] firstObject];
		[controller setEditUser:YES];
	}

}

- (IBAction)changePhoto:(id)sender
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	
	UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Take photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		dispatch_async(dispatch_get_main_queue(), ^(void){
			UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Content" bundle:nil];
			CameraViewController *controller = [storyboard instantiateInitialViewController];
			[controller setDisableVideo:YES];
			[self presentViewController:controller animated:YES completion:nil];
			
			controller.contentCaptured = ^(NSURL *url, UIImage *image){
				[self saveImage:image];
			};
			
		});
		
	}];
	[alert addAction:camera];
	UIAlertAction *library = [UIAlertAction actionWithTitle:@"Photo library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self presentViewController:self.picker1 animated:YES completion:nil];
		
	}];
	
	UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
	}];
	
	[alert addAction:library];
	[alert addAction:cancel];
	
	[self presentViewController:alert animated:YES completion:nil];
}

- (void)saveImage:(UIImage*)image
{
	[[[[[DataManager sharedInstance] refStorage] child:@"profile"] child:[FIRAuth auth].currentUser.uid] putData:UIImageJPEGRepresentation(image, 0.3) metadata:nil completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
		[[[[[DataManager sharedInstance] refDatabase] child:@"users"] child:[FIRAuth auth].currentUser.uid] updateChildValues:@{@"photoURL":[metadata.downloadURL absoluteString],@"photoPath":metadata.path} withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
			
		}];
	}];
	[self.detailImageView1 setImage:image];
}

#pragma mark - Keyboard
- (void)addObserver
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)removeObserver
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

#pragma mark - Keyboard Notifications
- (void)keyboardFrameChange:(NSNotification*)notification
{
	CGRect frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGFloat offset = self.view.frame.size.height-frame.size.height-self.floatView.frame.size.height;
	[self.floatView setFrame:CGRectMake(self.floatView.view.frame.origin.x, offset, self.floatView.frame.size.width, self.floatView.frame.size.height)];

}

- (void)keyboardWillShow:(NSNotification*)notification
{
	CGRect frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGFloat offset = self.view.frame.size.height-frame.size.height-self.floatView.frame.size.height;
	[self.floatView setFrame:CGRectMake(self.floatView.view.frame.origin.x, offset, self.floatView.frame.size.width, self.floatView.frame.size.height)];
	[self.tableView setContentInset:UIEdgeInsetsMake(0, 0, frame.size.height+self.floatView.frame.size.height, 0)];

}

- (void)keyboardDidHide:(NSNotification*)notification
{
	CGRect frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	CGFloat offset = self.view.frame.size.height-frame.size.height-self.floatView.frame.size.height;
	[self.floatView setFrame:CGRectMake(self.floatView.view.frame.origin.x, offset, self.floatView.frame.size.width, self.floatView.frame.size.height)];
	[self.tableView setContentInset:UIEdgeInsetsMake(0, 0, self.tabBarController.tabBar.frame.size.height, 0)];

}


#pragma mark - UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self removeObserver];
#warning TODO: Add search for existing name
	[[[[[DataManager sharedInstance] refDatabase] child:@"users"] child:[FIRAuth auth].currentUser.uid] updateChildValues:@{@"displayName":textField.text}];
	[self.floatView removeFromSuperview];
	
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	return YES;
}

- (void)cancelNameChange:(id)sender
{
	[self.view endEditing:YES];
	[self removeObserver];
	[self.floatView removeFromSuperview];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - UIImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
	UIImage *image = info[UIImagePickerControllerEditedImage];
	[self saveImage:image];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:^{
		//.. done dismissing
	}];
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *title = self.data[indexPath.section][indexPath.row];
	if (indexPath.section == 0 && indexPath.row == 0) {
		self.floatView = [[BRFloatTextView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-self.tabBarController.tabBar.frame.size.height-45,self.view.frame.size.width, 45)];
		//[self.floatView.textField1 setAutocorrectionType:UITextAutocorrectionTypeNo];
		[self.view addSubview:self.floatView];
		[self.floatView.button1 addTarget:self action:@selector(cancelNameChange:) forControlEvents:UIControlEventTouchUpInside];
		[self.floatView.button1 setTitle:@"Cancel" forState:UIControlStateNormal];
		//[self.floatView.textField1 addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
		[self.floatView.textField1 setDelegate:self];
		[self.floatView.textField1 setReturnKeyType:UIReturnKeyDone];
		[self.floatView.textField1 setPlaceholder:[DataManager sharedInstance].user.displayName];
		[self.floatView.textField1 becomeFirstResponder];
		//[sender setTitle:@"Cancel Add Comment" forState:UIControlStateNormal];
		
		[self addObserver];
	}
	
	if ([title isEqualToString:@"Logout"]) {
		[self logout:self];
	}
	if ([title isEqualToString:@"Change Password"]) {
		BRAlertView *alert = [BRAlertView brandedInstance];
		
		UITextField *textField1 = [alert addTextField:@"New Password"];
		[textField1 setSecureTextEntry:YES];
		
		[alert addButton:@"Continue" actionBlock:^(void) {
			FIRUser *user = [FIRAuth auth].currentUser;
			
			[user updatePassword:textField1.text completion:^(NSError *_Nullable error) {
				if (error) {
					// An error happened.
					BRAlertView *alert = [BRAlertView brandedInstance];
					[alert showEdit:self title:@"Error" subTitle:error.description closeButtonTitle:@"OK" duration:0.0f];
				} else {
					// Password updated.
					BRAlertView *alert = [BRAlertView brandedInstance];
					[alert showEdit:self title:@"Password Changed" subTitle:@"You will need to relog in new password." closeButtonTitle:@"OK" duration:0.0f];
					[alert alertIsDismissed:^{
						[self logout:self];
					}];
				}
			}];
		}];
		
		[alert showEdit:self title:@"New Password" subTitle:nil closeButtonTitle:@"Cancel" duration:0.0f];
		[alert alertIsDismissed:^{
			[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
		}];
	}
	
	if ([title isEqualToString:@"Edit my topics"]) {
		[self performSegueWithIdentifier:@"Topics" sender:self];
	}
}

#pragma mark - UITableView Datasource
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.data count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.data[section] count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default"];
	[cell.titleLabel setText:self.data[indexPath.section][indexPath.row]];
	if (indexPath.section == 0 && indexPath.row == 0) {
		[cell.detailImageView setHidden:NO];
	}else{
		[cell.detailImageView setHidden:YES];
	}
	
	return cell;
}

@end
