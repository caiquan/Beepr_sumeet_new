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
#import "people.h"
#import "recent.h"

#import "PeopleView.h"
#import "ProfileView.h"
#import "SelectSingleView.h"
#import "SelectMultipleView.h"
#import "AddressBookView.h"
#import "NavigationController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface PeopleView()
{
	BOOL skipLoading;
	NSMutableArray *users;
	NSMutableArray *userIds;
	NSMutableArray *sections;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation PeopleView
@synthesize bannerView;
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_people"]];
		self.tabBarItem.title = @"People";
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
	self.title = @"People";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
																						   action:@selector(actionAdd)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableFooterView = [[UIView alloc] init];
     self.tableView.tableHeaderView = bannerView;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	users = [[NSMutableArray alloc] init];
	userIds = [[NSMutableArray alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
//    [self adBanner];
}
-(void)adBanner
{
    self.bannerView.adUnitID = @"ca-app-pub-4886788404179515/8149650981";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([CatalyzeUser currentUser] != nil)
	{
		if (skipLoading) skipLoading = NO; else [self loadPeople];
	}
	else LoginUser(self);
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadPeople
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_PEOPLE_CLASS_NAME];
    [query setPageNumber:1];
    [query setPageSize:1000];
    [query retrieveInBackgroundWithSuccess:^(NSArray* result){
        [users removeAllObjects];
        for(CatalyzeEntry *entry in result){
            if([[entry content] valueForKey:PF_PEOPLE_USER2] != nil ){
                [users addObject:[[B_USER alloc] initWithDictionary:[[entry content] valueForKey:@"objUser2"]]];
                [userIds addObject:[[entry content] valueForKey:PF_PEOPLE_USER2]];
            }
        }
        [self setObjects:users];
        [self.tableView reloadData];
    } failure:^(NSDictionary *result, int status, NSError* error){
        [ProgressHUD showError:@"Network error."];
    }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setObjects:(NSArray *)objects
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (sections != nil) [sections removeAllObjects];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSInteger sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
	sections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (NSUInteger i=0; i<sectionTitlesCount; i++)
	{
		[sections addObject:[NSMutableArray array]];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *sorted = [objects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
	{
		B_USER *user1 = (B_USER *)obj1;
		B_USER *user2 = (B_USER *)obj2;
		return [[user1 getFullName] compare:[user2 getFullName]];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (CatalyzeUser *object in sorted)
	{
		NSInteger section = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:@selector(getFullName)];
		[sections[section] addObject:object];
	}
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[users removeAllObjects];
	[userIds removeAllObjects];
	[sections removeAllObjects];
	[self.tableView reloadData];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAdd
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
								   otherButtonTitles:@"Search user", @"Select users", @"Address Book", nil];
	[action showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		skipLoading = YES;
		if (buttonIndex == 0)
		{
			SelectSingleView *selectSingleView = [[SelectSingleView alloc] init];
			selectSingleView.delegate = self;
			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectSingleView];
			[self presentViewController:navController animated:YES completion:nil];
		}
		if (buttonIndex == 1)
		{
			SelectMultipleView *selectMultipleView = [[SelectMultipleView alloc] init];
			selectMultipleView.delegate = self;
			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectMultipleView];
			[self presentViewController:navController animated:YES completion:nil];
		}
		if (buttonIndex == 2)
		{
			AddressBookView *addressBookView = [[AddressBookView alloc] init];
			addressBookView.delegate = self;
			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:addressBookView];
			[self presentViewController:navController animated:YES completion:nil];
		}
	}
}

#pragma mark - SelectSingleDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectSingleUser:(B_USER *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self addUser:user];
}

#pragma mark - SelectMultipleDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectMultipleUsers:(NSMutableArray *)users_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	for (B_USER *user in users_)
	{
		[self addUser:user];
	}
}

#pragma mark - AddressBookDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectAddressBookUser:(B_USER *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self addUser:user];
}

#pragma mark - FacebookFriendsDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectFacebookUser:(B_USER *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self addUser:user];
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)addUser:(B_USER *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if ([userIds containsObject:[user getObjectId]] == NO)
	{
     	PeopleSaveWithBUser([[B_USER alloc] initWithCatalyzeUser:[CatalyzeUser currentUser]], user);
        [users addObject:user];
		[userIds addObject:[user getObjectId]];
		[self setObjects:users];
		[self.tableView reloadData];
	}
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [sections count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [sections[section] count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([sections[section] count] != 0)
	{
		return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
	}
	else return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

	NSMutableArray *userstemp = sections[indexPath.section];
    B_USER * user = userstemp[indexPath.row];

	cell.textLabel.text = [user getFullName];

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
	NSMutableArray *userstemp = sections[indexPath.section];
    CatalyzeEntry * entry = userstemp[indexPath.row];
    B_USER *user = [[B_USER alloc] initWithCatalyzeEntry:entry];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PeopleDelete([[B_USER alloc] initWithCatalyzeUser:[CatalyzeUser currentUser]], user);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[users removeObject:user];
	[userIds removeObject:[user getObjectId]];
	[self setObjects:users];
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
	NSMutableArray *userstemp = sections[indexPath.section];
    B_USER * user = userstemp[indexPath.row];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	ProfileView *profileView = [[ProfileView alloc] initWith:[user getObjectId] User:user];
	profileView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:profileView animated:YES];
}

@end
