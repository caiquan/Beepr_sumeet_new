//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ProgressHUD.h"

#import "AppConstant.h"
#import "camera.h"
#import "common.h"
#import "image.h"
#import "push.h"

#import "SettingsView.h"
#import "BlockedView.h"
#import "PrivacyView.h"
#import "TermsView.h"
#import "NavigationController.h"
#import  "catalyze.h"
#import "UIImageView+AFNetworking.h"
//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface SettingsView(){
    BOOL flag;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelName;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellBlocked;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPrivacy;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellTerms;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellLogout;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation SettingsView

@synthesize viewHeader, imageUser, labelName;
@synthesize cellBlocked, cellPrivacy, cellTerms, cellLogout,bannerView;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_settings"]];
		self.tabBarItem.title = @"Settings";
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Settings";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewHeader;
    self.tableView.tableFooterView = bannerView;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
	imageUser.layer.masksToBounds = YES;
    flag = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([CatalyzeUser currentUser] != nil)
	{
        if(flag)
            [self loadUser];
	}
	else LoginUser(self);
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CatalyzeUser *user = [CatalyzeUser currentUser];
    if([user.avatar length] != 0){
        [CatalyzeFileManager retrieveFile:user.avatar success:
        ^(NSData * result){
            [imageUser setImage:[UIImage imageWithData:result]];
        }failure:^(NSDictionary * result, int status, NSError * error){
        }];
    }

//	[imageUser setFile:user[PF_USER_PICTURE]];
//	[imageUser loadInBackground];

	labelName.text = [user username];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionBlocked
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	BlockedView *blockedView = [[BlockedView alloc] init];
	blockedView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:blockedView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionPrivacy
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PrivacyView *privacyView = [[PrivacyView alloc] init];
	privacyView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:privacyView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionTerms
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	TermsView *termsView = [[TermsView alloc] init];
	termsView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:termsView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	imageUser.image = [UIImage imageNamed:@"settings_blank"];
	labelName.text = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogout
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
										  destructiveButtonTitle:@"Log out" otherButtonTitles:nil];
	[action showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
        [[CatalyzeUser currentUser] logout];
		PostNotification(NOTIFICATION_USER_LOGGED_OUT);
		[self actionCleanup];
		LoginUser(self);
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionPhoto:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PresentPhotoLibrary(self, YES);
}

#pragma mark - UIImagePickerControllerDelegate
+ (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    flag = NO;
	UIImage *image = info[UIImagePickerControllerEditedImage];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIImage *picture = ResizeImage(image, 140, 140, 1);
	UIImage *thumbnail = ResizeImage(image, 60, 60, 1);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.image = picture;
	//---------------------------------------------------------------------------------------------------------------------------------------------

    NSData *uploadFile = UIImageJPEGRepresentation(picture, 0.6);
    NSData *uploadFileOfThumb = UIImageJPEGRepresentation(thumbnail, 0.6);
    [CatalyzeFileManager uploadFileToUser:uploadFile phi:NO mimeType:[SettingsView contentTypeForImageData:uploadFile] success:^(NSDictionary *result) {
        [CatalyzeFileManager uploadFileToUser:uploadFileOfThumb phi:NO mimeType:[SettingsView contentTypeForImageData:uploadFileOfThumb]
                                      success:^(NSDictionary *_result) {
                                          
                                          CatalyzeUser *user = [CatalyzeUser currentUser];
                                          [user setValue:[result valueForKey:@"filesId"] forKey:@"profilePhoto"];
                                          [user setValue:[_result valueForKey:@"filesId"] forKey:@"avatar"];
                                          [user saveInBackground];
                                          CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_USER_CLASS_NAME];
                                          [query setPageNumber:1];
                                          [query setPageSize:20];
                                          [query setQueryField:PF_USER_OBJECTID];
                                          [query setQueryValue:user.usersId];
                                          [query retrieveInBackgroundWithSuccess:^(NSArray *result){
                                              CatalyzeEntry * entry = (CatalyzeEntry *)[result firstObject];
                                              [[entry content] setValue:[_result valueForKey:@"filesId"] forKey:@"profilePhoto"];
                                              [entry saveInBackgroundWithSuccess:^(id result){
                                                  NSLog(@"success save profile");
                                              } failure:^(NSDictionary * result, int status , NSError * error){
                                                  NSLog(@"fail save profile");
                                              }];
                                          } failure:^(NSDictionary * result, int status, NSError *error){
                                          }];
                                          
                                      }
                                      failure:^(NSDictionary *result, int status, NSError * error){
        }];
    } failure:^(NSDictionary *result, int status, NSError *error) {
        [ProgressHUD showError:@"Network error."];
    }];
    
//	PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
//	[filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//	{
//		if (error != nil) [ProgressHUD showError:@"Network error."];
//	}];
//	//---------------------------------------------------------------------------------------------------------------------------------------------
//	PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
//	[fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//	{
//		if (error != nil) [ProgressHUD showError:@"Network error."];
//	}];
//	//---------------------------------------------------------------------------------------------------------------------------------------------
//	PFUser *user = [PFUser currentUser];
//	user[PF_USER_PICTURE] = filePicture;
//	user[PF_USER_THUMBNAIL] = fileThumbnail;
//	[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//	{
//		if (error != nil) [ProgressHUD showError:@"Network error."];
//	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 2;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 0) return 3;
	if (section == 1) return 1;
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellBlocked;
	if ((indexPath.section == 0) && (indexPath.row == 1)) return cellPrivacy;
	if ((indexPath.section == 0) && (indexPath.row == 2)) return cellTerms;
	if ((indexPath.section == 1) && (indexPath.row == 0)) return cellLogout;
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 0) && (indexPath.row == 0)) [self actionBlocked];
	if ((indexPath.section == 0) && (indexPath.row == 1)) [self actionPrivacy];
	if ((indexPath.section == 0) && (indexPath.row == 2)) [self actionTerms];
	if ((indexPath.section == 1) && (indexPath.row == 0)) [self actionLogout];
}
-(void) viewWillAppear:(BOOL)animated
{
//    [self adBanner];
}

-(void)adBanner
{
    self.bannerView.adUnitID = @"ca-app-pub-4886788404179515/8149650981";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
}

@end
