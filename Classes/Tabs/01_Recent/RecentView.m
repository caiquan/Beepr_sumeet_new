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
#import <Firebase/Firebase.h>

#import "AppConstant.h"
#import "common.h"
#import "converter.h"
#import "recent.h"

#import "RecentView.h"
#import "RecentCell.h"
#import "ChatView.h"
#import "SelectSingleView.h"
#import "SelectMultipleView.h"
#import "AddressBookView.h"
#import "NavigationController.h"
//-------------------------------------------------------------------------------------------------------------------------------------------------
#import "Catalyze.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RecentView()
{
	NSMutableArray *recents;
   	Firebase *firebase;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RecentView
@synthesize bannerView;
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_recent"]];
		self.tabBarItem.title = @"Recent";
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRecents) name:NOTIFICATION_APP_STARTED object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRecents) name:NOTIFICATION_USER_LOGGED_IN object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT object:nil];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Recent";
	//---------------------------------------------------------------------------------------------------------------------------------------------
//    self.tableView.tableHeaderView = bannerView;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self
																						   action:@selector(actionCompose)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView registerNib:[UINib nibWithNibName:@"RecentCell" bundle:nil] forCellReuseIdentifier:@"RecentCell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	recents = [[NSMutableArray alloc] init];
}
-(void)viewWillAppear:(BOOL)animated{
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
{
	[super viewDidAppear:animated];

    if([CatalyzeUser currentUser] != nil){
    }
    else LoginUser(self);
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadRecents
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeUser * _user = [CatalyzeUser currentUser];
    if(_user !=nil && firebase == nil){
        firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
        
        FQuery *query = [[firebase queryOrderedByChild:@"userId"] queryEqualToValue:_user.usersId];
        [query observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
         {
             [recents removeAllObjects];
             if (snapshot.value != [NSNull null])
             {
                 NSArray *sorted = [[snapshot.value allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                                    {
                                        NSDictionary *recent1 = (NSDictionary *)obj1;
                                        NSDictionary *recent2 = (NSDictionary *)obj2;
                                        NSDate *date1 = String2Date(recent1[@"date"]);
                                        NSDate *date2 = String2Date(recent2[@"date"]);
                                        return [date2 compare:date1];
                                    }];
                 for (NSDictionary *recent in sorted)
                 {
                     [recents addObject:recent];
                 }
             }
             [self.tableView reloadData];
             [self updateTabCounter];
         }];
    }
	
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateTabCounter
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	int total = 0;
	for (NSDictionary *recent in recents)
	{
		total += [recent[@"counter"] intValue];
	}
	UITabBarItem *item = self.tabBarController.tabBar.items[0];
	item.badgeValue = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionChat:(NSString *)groupId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ChatView *chatView = [[ChatView alloc] initWith:groupId];
	chatView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:chatView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[firebase removeAllObservers];
	firebase = nil;
	[recents removeAllObjects];
	[self.tableView reloadData];
	[self updateTabCounter];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCompose
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
			   otherButtonTitles:@"Single recipient", @"Multiple recipients", @"Address Book", nil];
	[action showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
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
//		if (buttonIndex == 3)
//		{
//			FacebookFriendsView *facebookFriendsView = [[FacebookFriendsView alloc] init];
//			facebookFriendsView.delegate = self;
//			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:facebookFriendsView];
//			[self presentViewController:navController animated:YES completion:nil];
//		}
	}
}

#pragma mark - SelectSingleDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectSingleUser:(B_USER *)user2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CatalyzeUser *user1 = [CatalyzeUser currentUser];
    B_USER *bUser1 = [[B_USER alloc] initWithCatalyzeUser:user1];
    
//	NSString *groupId = StartPrivateChat(user1, user2);
    NSString *groupId = StartPrivateChatWithBuser(bUser1, user2);
	[self actionChat:groupId];
}

#pragma mark - SelectMultipleDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectMultipleUsers:(NSMutableArray *)users
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *groupId = StartMultipleChat(users);
	[self actionChat:groupId];
}

#pragma mark - AddressBookDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectAddressBookUser:(CatalyzeUser *)user2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CatalyzeUser *user1 = [CatalyzeUser currentUser];
    B_USER *bUser1 = [[B_USER alloc] initWithCatalyzeUser:user1];
    B_USER *bUser2 = [[B_USER alloc] initWithCatalyzeUser:user2];
    
//	NSString *groupId = StartPrivateChat(user1, user2);
    NSString *groupId = StartPrivateChatWithBuser(bUser1, bUser2);
	[self actionChat:groupId];
}

#pragma mark - FacebookFriendsDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectFacebookUser:(CatalyzeUser *)user2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CatalyzeUser *user1 = [CatalyzeUser currentUser];
    B_USER *bUser1 = [[B_USER alloc] initWithCatalyzeUser:user1];
    B_USER *bUser2 = [[B_USER alloc] initWithCatalyzeUser:user2];

    NSString *groupId = StartPrivateChatWithBuser(bUser1, bUser2);
	[self actionChat:groupId];
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
	return [recents count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RecentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecentCell" forIndexPath:indexPath];
	[cell bindData:recents[indexPath.row]];
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
	NSDictionary *recent = recents[indexPath.row];
	[recents removeObject:recent];
	[self updateTabCounter];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	DeleteRecentItem(recent);
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDictionary *recent = recents[indexPath.row];
	[self actionChat:recent[@"groupId"]];
}

#pragma mark - PushNotificationHandler

- (void)handleNotification:(NSString *)fromNumber {
    NSLog(@"I got a msg, querying for it...");
    [self queryMessages];
}

- (void)queryMessages {
    NSLog(@"recieve push notification");
//    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:@"messages"];
//    query.queryField = @"conversationsId";
//    query.queryValue = _conversationsId;
//    query.pageNumber = 1;
//    query.pageSize = 100;
//    [query retrieveInBackgroundWithSuccess:^(NSArray *result) {
//        [_messages removeAllObjects];
//        for (CatalyzeEntry *entry in result) {
//            // can't query by conversationsId and parentId, so we have to filter once we get the results back
//            if ([[entry parentId] isEqualToString:[[CatalyzeUser currentUser] usersId]]) {
//                [_messages addObject:[[Message alloc] initWithClassName:@"messages" dictionary:[entry content]]];
//            }
//        }
//        [_messages sortUsingComparator:^NSComparisonResult(Message *msg1, Message *msg2) {
//            return [[[msg1 content] valueForKey:@"timestamp"] compare:[[msg2 content] valueForKey:@"timestamp"]];
//        }];
//        [_tblMessages reloadData];
//        //[self scrollToBottomAnimated:YES];
//    } failure:^(NSDictionary *result, int status, NSError *error) {
//        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not fetch previous messages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//    }];
}

@end
