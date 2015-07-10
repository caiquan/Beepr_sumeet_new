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

#import "SelectSingleView.h"
#import "catalyze.h"
#import "B_USER.h"
//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface SelectSingleView()
{
	NSMutableArray *users;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL bannerViewHide = false;
@implementation SelectSingleView

@synthesize delegate;
@synthesize viewHeader, searchBar,bannerView;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Select Single";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
																						  action:@selector(actionCancel)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
    
	self.tableView.tableHeaderView = viewHeader;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	users = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadUsers];
}
-(void) adjustViewForBanner
{
}
- (void)viewWillAppear:(BOOL)animated
{
    
    
    
    bannerView.hidden = bannerViewHide;
    [self adjustViewForBanner];
    
    [super viewWillAppear:animated];
//    [self adBanner];
    
    
}

-(void)adBanner
{
    self.bannerView.adUnitID = @"ca-app-pub-4886788404179515/8149650981";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
	[self dismissKeyboard];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUsers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
    CatalyzeUser *user = [CatalyzeUser currentUser];
    [query setQueryField:PF_BLOCKED_USER1];
    [query setQueryValue:user.usersId];
    [query setPageNumber:1];
    [query setPageSize:100];
    [query retrieveInBackgroundWithSuccess:^(NSArray* result){
        CatalyzeQuery *query1 = [CatalyzeQuery queryWithClassName:PF_USER_CLASS_NAME];
        [query1 setPageSize:100];
        [query1 setPageNumber:1];
        [query1 retrieveAllEntriesInBackgroundWithSuccess:^(NSArray* _result){
            NSArray * blocked = [(CatalyzeEntry*)[result firstObject] valueForKey:PF_BLOCKED_USER2];
            [users removeAllObjects];
            for(CatalyzeEntry* entry in _result){
                B_USER *bUser = [[B_USER alloc]initWithCatalyzeEntry:entry];
                
                if(![[bUser getObjectId] isEqualToString:user.usersId] &&
                   ![blocked containsObject:[bUser getObjectId]]){
                    [users addObject:bUser];
                }
            }
            [self.tableView reloadData];
        }failure:^(NSDictionary* result, int status, NSError* error){
            [ProgressHUD showError:@"Network error."];
        }];

    }failure:^(NSDictionary* result, int status, NSError * error){
    }];
//	PFUser *user = [PFUser currentUser];
//
//	PFQuery *query1 = [PFQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
//	[query1 whereKey:PF_BLOCKED_USER1 equalTo:user];
//
//	PFQuery *query2 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
//	[query2 whereKey:PF_USER_OBJECTID notEqualTo:user.objectId];
//	[query2 whereKey:PF_USER_OBJECTID doesNotMatchKey:PF_BLOCKED_USERID2 inQuery:query1];
//	[query2 orderByAscending:PF_USER_FULLNAME_LOWER];
//	[query2 setLimit:1000];
//	[query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//	{
//		if (error == nil)
//		{
//			[users removeAllObjects];
//			[users addObjectsFromArray:objects];
//			[self.tableView reloadData];
//		}
//		else [ProgressHUD showError:@"Network error."];
//	}];
    

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchUsers:(NSString *)search_lower
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeUser *user = [CatalyzeUser currentUser];
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];

    [query setQueryField:PF_BLOCKED_USER1];
    [query setQueryValue:user.usersId];
    [query setPageNumber:1];
    [query setPageSize:1000];
    [query retrieveInBackgroundWithSuccess:^(NSArray* result){
        CatalyzeQuery *query1 = [CatalyzeQuery queryWithClassName:PF_USER_CLASS_NAME];
        [query1 setPageSize:1000];
        [query1 setPageNumber:1];
        [query retrieveInBackgroundWithSuccess:^(NSArray* _result){
            NSArray * blocked = [(CatalyzeEntry*)[result firstObject] valueForKey:PF_BLOCKED_USER2];
            [users removeAllObjects];
            for(CatalyzeEntry* entry in _result){
                if(![[[entry content] valueForKey:PF_USER_OBJECTID] isEqualToString:user.usersId] &&
                   ![blocked containsObject:[[entry content] valueForKey:PF_USER_OBJECTID]] &&
                   [[[entry content] valueForKey:PF_USER_FULLNAME_LOWER] containsString:[user.username lowercaseString]]){
                    [users addObject:entry];
                }
            }
            [self.tableView reloadData];
        }failure:^(NSDictionary* result, int status, NSError* error){
            [ProgressHUD showError:@"Network error."];
        }];
        
    }failure:^(NSDictionary* result, int status, NSError * error){
    }];
    
//    PFUser *user = [PFUser currentUser];
//
//	PFQuery *query1 = [PFQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
//	[query1 whereKey:PF_BLOCKED_USER1 equalTo:user];
//
//	PFQuery *query2 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
//	[query2 whereKey:PF_USER_OBJECTID notEqualTo:user.objectId];
//	[query2 whereKey:PF_USER_OBJECTID doesNotMatchKey:PF_BLOCKED_USERID2 inQuery:query1];
//	[query2 whereKey:PF_USER_FULLNAME_LOWER containsString:search_lower];
//	[query2 orderByAscending:PF_USER_FULLNAME_LOWER];
//	[query2 setLimit:1000];
//	[query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//	{
//		if (error == nil)
//		{
//			[users removeAllObjects];
//			[users addObjectsFromArray:objects];
//			[self.tableView reloadData];
//		}
//		else [ProgressHUD showError:@"Network error."];
//	}];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissKeyboard];
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
	return [users count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

    B_USER* user = users[indexPath.row];
	cell.textLabel.text = [user getFullName];

	return cell;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self dismissViewControllerAnimated:YES completion:^{
		if (delegate != nil) [delegate didSelectSingleUser:users[indexPath.row]];
	}];
}

#pragma mark - UISearchBarDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([searchText length] > 0)
	{
		[self searchUsers:[searchText lowercaseString]];
	}
	else [self loadUsers];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[searchBar_ setShowsCancelButton:YES animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[searchBar_ setShowsCancelButton:NO animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self searchBarCancelled];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[searchBar_ resignFirstResponder];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarCancelled
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	searchBar.text = @"";
	[searchBar resignFirstResponder];

	[self loadUsers];
}

@end
