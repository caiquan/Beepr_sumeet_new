
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "blocked.h"

#import "BlockedView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
#import "catalyze.h"
//-------------------------------------------------------------------------------------------------------------------------------------------------

@interface BlockedView()
{
	NSMutableArray *blockeds;
	NSIndexPath *indexSelected;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation BlockedView
@synthesize bannerView;
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Blocked users";
    self.tableView.tableHeaderView = bannerView;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	blockeds = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadBlockeds];
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
#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadBlockeds
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
    [query setPageNumber:1];
    [query setPageSize:1000];
    [query retrieveAllEntriesInBackgroundWithSuccess:^(NSArray *result){
        [blockeds removeAllObjects];
        
        for(CatalyzeEntry *entry in result){
            if([[[entry content] valueForKey:PF_BLOCKED_USER] isEqualToString:[[CatalyzeUser currentUser] usersId]] &&
               [[[entry content] valueForKey:PF_BLOCKED_USER1] isEqualToString:[[CatalyzeUser currentUser] usersId]] ){
                [blockeds addObject:entry];
                [self.tableView reloadData];
            }
        }
    }
    failure:^(NSDictionary *result , int status, NSError *error){
        [ProgressHUD showError:@"Network error."];
    }];
//	PFQuery *query = [PFQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
//	[query whereKey:PF_BLOCKED_USER equalTo:[PFUser currentUser]];
//	[query whereKey:PF_BLOCKED_USER1 equalTo:[PFUser currentUser]];
//	[query includeKey:PF_BLOCKED_USER2];
//	[query setLimit:1000];
//	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//	{
//		if (error == nil)
//		{
//			[blockeds removeAllObjects];
//			[blockeds addObjectsFromArray:objects];
//			[self.tableView reloadData];
//		}
//		else [ProgressHUD showError:@"Network error."];
//	}];
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
	return [blockeds count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

    CatalyzeEntry *blocked = blockeds[indexPath.row];
    CatalyzeUser *user = [[blocked content] valueForKey:PF_BLOCKED_USER2];
//	PFObject *blocked = blockeds[indexPath.row];
//	PFUser *user = blocked[PF_BLOCKED_USER2];
//	cell.textLabel.text = user[PF_USER_FULLNAME];
  	cell.textLabel.text = [user username];

	return cell;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	indexSelected = indexPath;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
										  destructiveButtonTitle:nil otherButtonTitles:@"Unblock user", nil];
	[action showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
        CatalyzeEntry *blocked = blockeds[indexSelected.row];
        CatalyzeUser *user = [[blocked content] valueForKey:PF_BLOCKED_USER2];
//		PFObject *blocked = blockeds[indexSelected.row];
//		PFUser *user2 = blocked[PF_BLOCKED_USER2];
		//-----------------------------------------------------------------------------------------------------------------------------------------
//		UnblockUser(user2);
        UnblockUser(user);
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[blockeds removeObject:blocked];
		[self.tableView reloadData];
	}
}

@end
