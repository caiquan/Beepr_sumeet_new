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

#import <catalyze.h>
#import "UIImageView+AFNetworking.h"
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "blocked.h"
#import "recent.h"
#import "report.h"

#import "ProfileView.h"
#import "ChatView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ProfileView()
{
	NSString *userId;
	B_USER *user;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelName;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellChat;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellReport;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellBlock;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ProfileView

@synthesize viewHeader, imageUser, labelName;
@synthesize cellChat, cellReport, cellBlock,bannerView;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)userId_ User:(B_USER *)user_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	userId = userId_;
	user = user_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Profile";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewHeader;
    self.tableView.tableFooterView = bannerView;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
	imageUser.layer.masksToBounds = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillAppear:animated];
//    [self adBanner];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (user != nil)
	{
		[self showUserDetails];
	}
	else [self loadUser];
}
-(void)adBanner
{
    self.bannerView.adUnitID = @"ca-app-pub-4886788404179515/8149650981";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];

}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query setPageSize:1000];
    [query setPageNumber:1];
    [query setQueryField:PF_USER_OBJECTID];
    [query setQueryValue:userId];
    [query retrieveInBackgroundWithSuccess:^(NSArray *result){
        CatalyzeEntry * entry = (CatalyzeEntry *)[result firstObject];
        if(entry !=nil){
            	[self showUserDetails];
        }
    } failure:^(NSDictionary* result , int status, NSError *error){
        [ProgressHUD showError:@"Network error."];
    }];
//	PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
//	[query whereKey:PF_USER_OBJECTID equalTo:userId];
//	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//	{
//		if (error == nil)
//		{
//			user = [objects firstObject];
//			if (user != nil)
//			{
//				[self showUserDetails];
//			}
//		}
//		else [ProgressHUD showError:@"Network error."];
//	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)showUserDetails
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
   	labelName.text = [user getFullName];
    
    if([user getProfilePhoto] == (id)[NSNull null])
        return;
    
    [CatalyzeFileManager retrieveFileFromUser:[user getProfilePhoto] usersId:[user getObjectId] success:^(NSData *result) {
        imageUser.image = [UIImage imageWithData:result];
    } failure:^(NSDictionary *result, int status, NSError *error) {
        //something went wrong, check the result dictionary
    }];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionChat
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (user != nil)
	{
        CatalyzeUser * user1 = [CatalyzeUser currentUser];
        
        B_USER *b_user1 = [[B_USER alloc] initWithCatalyzeUser:user1];
        
        NSString *groupId = StartPrivateChatWithBuser(b_user1, user);
		ChatView *chatView = [[ChatView alloc] initWith:groupId];
		[self.navigationController pushViewController:chatView animated:YES];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionReport
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
										  destructiveButtonTitle:nil otherButtonTitles:@"Report user", nil];
	action.tag = 1;
	[action showInView:self.view];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionBlock
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
										  destructiveButtonTitle:@"Block user" otherButtonTitles:nil];
	action.tag = 2;
	[action showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (actionSheet.tag == 1) [self actionSheet:actionSheet clickedButtonAtIndex1:buttonIndex];
	if (actionSheet.tag == 2) [self actionSheet:actionSheet clickedButtonAtIndex2:buttonIndex];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex1:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		if (user != nil)
		{
			ReportUser(user);
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex2:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		if (user != nil)
		{
			BlockUser(user);
			[ProgressHUD show:nil Interaction:NO];
			[self performSelector:@selector(delayedPopToRootViewController) withObject:nil afterDelay:1.0];
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)delayedPopToRootViewController
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[ProgressHUD dismiss];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 3;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellChat;
	if ((indexPath.section == 0) && (indexPath.row == 1)) return cellReport;
	if ((indexPath.section == 0) && (indexPath.row == 2)) return cellBlock;
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 0) && (indexPath.row == 0)) [self actionChat];
	if ((indexPath.section == 0) && (indexPath.row == 1)) [self actionReport];
	if ((indexPath.section == 0) && (indexPath.row == 2)) [self actionBlock];
}

@end
