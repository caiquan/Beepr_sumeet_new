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
#import "recent.h"

#import "GroupSettingsView.h"
#import "ChatView.h"
#import "ProfileView.h"
#import "B_USER.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface GroupSettingsView()
{
	CatalyzeEntry *group;
	NSMutableArray *users;
}

@property (strong, nonatomic) IBOutlet UITableViewCell *cellName;

@property (strong, nonatomic) IBOutlet UILabel *labelName;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation GroupSettingsView

@synthesize cellName;
@synthesize labelName,bannerView;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(CatalyzeEntry *)group_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	group = group_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Group Settings";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	users = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
//    self.tableView.tableHeaderView = bannerView;
	[self loadGroup];
	[self loadUsers];
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadGroup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	labelName.text = [[group content] valueForKey:PF_GROUP_NAME];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUsers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeUser *user = [CatalyzeUser currentUser];
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query setPageNumber:1];
    [query setPageSize:1000];
    [query retrieveAllEntriesInBackgroundWithSuccess:^(NSArray * result){
        B_USER* bGroup = [[B_USER alloc] initWithCatalyzeEntry:group];
        [users removeAllObjects];
        for(CatalyzeEntry *entry in result){
            B_USER* bUser = [[B_USER alloc] initWithCatalyzeEntry:entry];
            if([[bGroup getGroupMember] containsObject:[bUser getObjectId]] &&
               ![[bUser getObjectId] isEqualToString:user.usersId]){
                [users addObject:[[B_USER alloc] initWithCatalyzeEntry:entry]];
            }
        }
        [self.tableView reloadData];
    }failure:^(NSDictionary * result, int status, NSError *error){
        [ProgressHUD showError:@"Network error."];
    }];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionChat
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *groupId = [group valueForKey:@"entryId"];

	//---------------------------------------------------------------------------------------------------------------------------------------------
	StartGroupChat(group, users);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	ChatView *chatView = [[ChatView alloc] initWith:groupId];
	[self.navigationController pushViewController:chatView animated:YES];
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
	if (section == 0) return 1;
	if (section == 1) return [users count];
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 1) return @"Members";
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellName;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.section == 1)
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
		if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

		B_USER *user = users[indexPath.row];
		cell.textLabel.text = [user getFullName];

		return cell;
	}
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
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.section == 1)
	{
		B_USER *user = users[indexPath.row];
        CatalyzeUser *curUser = [CatalyzeUser currentUser];
        
		if ([[user getObjectId] isEqualToString:curUser.usersId] == NO)
		{
			ProfileView *profileView = [[ProfileView alloc] initWith:nil User:user];
			[self.navigationController pushViewController:profileView animated:YES];
		}
	}
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
