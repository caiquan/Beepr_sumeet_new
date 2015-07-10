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
#import "ProgressHUD.h"
#import "PFUser+Util.h"

#import "AppConstant.h"
#import "common.h"
#import "group.h"
#import "recent.h"

#import "GroupsView.h"
#import "CreateGroupView.h"
#import "GroupSettingsView.h"
#import "NavigationController.h"
#import "B_Group.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface GroupsView()
{
	NSMutableArray *groups;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation GroupsView
@synthesize bannerView;
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_groups"]];
		self.tabBarItem.title = @"Groups";
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT object:nil];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Groups";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
																						   action:@selector(actionNew)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
//    self.tableView.tableHeaderView = bannerView;
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(loadGroups) forControlEvents:UIControlEventValueChanged];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	groups = [[NSMutableArray alloc] init];
}
-(void)viewWillAppear:(BOOL)animated{
//    [self adBanner];
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([CatalyzeUser currentUser] != nil)
	{
		[self loadGroups];
	}
	else LoginUser(self);
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadGroups
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeUser *user = [CatalyzeUser currentUser];
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_GROUP_CLASS_NAME];
    [query setPageNumber:1];
    [query setPageSize:1000];

    [query retrieveAllEntriesInBackgroundWithSuccess:^(NSArray* result){
        
		[groups removeAllObjects];
        for(CatalyzeEntry * entry in result){
            B_Group *group = [[B_Group alloc] initWithEntry:entry];
            if([[group getMemebers] containsObject:user.usersId])
               [groups addObject:entry];
        }

        [self.tableView reloadData];
		[self.refreshControl endRefreshing];
        
    } failure:^(NSDictionary* result, int status, NSError *error){
        [ProgressHUD showError:@"Network error."];
    }];
    
//	PFUser *user = [PFUser currentUser];
//
//	PFQuery *query = [PFQuery queryWithClassName:PF_GROUP_CLASS_NAME];
//	[query whereKey:PF_GROUP_MEMBERS equalTo:user.objectId];
//	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//	{
//		if (error == nil)
//		{
//			[groups removeAllObjects];
//			[groups addObjectsFromArray:objects];
//			[self.tableView reloadData];
//		}
//		else [ProgressHUD showError:@"Network error."];
//		[self.refreshControl endRefreshing];
//	}];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionNew
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CreateGroupView *createGroupView = [[CreateGroupView alloc] init];
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:createGroupView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[groups removeAllObjects];
	[self.tableView reloadData];
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
	return [groups count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

    CatalyzeEntry *group = groups[indexPath.row];
	cell.textLabel.text = [[group content] valueForKey:PF_GROUP_NAME];

    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d members", (int) [[[group content] valueForKey:PF_GROUP_MEMBERS] count]];
	cell.detailTextLabel.textColor = [UIColor lightGrayColor];

	return cell;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeEntry *entry = groups[indexPath.row];
    B_Group *group = [[B_Group alloc]initWithEntry:entry];
    
    [groups removeObject:entry];
    
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CatalyzeUser *user1 = [CatalyzeUser currentUser];
	NSString *user2 = [[entry content] valueForKey:PF_GROUP_USER];
	//---------------------------------------------------------------------------------------------------------------------------------------------
    if([user1.usersId isEqualToString:user2]) RemoveGroupItem(entry); else RemoveGroupMember(group, [[B_USER alloc] initWithCatalyzeUser:user1]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	GroupSettingsView *groupSettingsView = [[GroupSettingsView alloc] initWith:groups[indexPath.row]];
	groupSettingsView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:groupSettingsView animated:YES];
}
-(void)adBanner
{
    //    if (bannerViewHide == false)
    //    {
    //        [FlurryAds enableTestAds:YES];
    //[FlurryAds fetchAndDisplayAdForSpace:@"Zero Banner" view:self.bannerView size:BANNER_BOTTOM];
    self.bannerView.adUnitID = @"ca-app-pub-4886788404179515/8149650981";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    //    }
}
@end
