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
#import "PFUser+Util.h"

#import "AppConstant.h"
#import "common.h"
#import "B_USER.h"
#import "B_People.h"
#import "CreateGroupView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
#include "catalyze.h"
//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface CreateGroupView()
{
	NSMutableArray *users;
	NSMutableArray *sections;
	NSMutableArray *selection;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UITextField *fieldName;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation CreateGroupView

@synthesize viewHeader, fieldName;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Create Group";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
																						  action:@selector(actionCancel)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self
																						   action:@selector(actionDone)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
	[self.tableView addGestureRecognizer:gestureRecognizer];
	gestureRecognizer.cancelsTouchesInView = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewHeader;
	self.tableView.tableFooterView = [[UIView alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	users = [[NSMutableArray alloc] init];
	selection = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadPeople];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	[fieldName becomeFirstResponder];
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

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadPeople
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_PEOPLE_CLASS_NAME];
    [query setQueryField:PF_PEOPLE_USER1];
    [query setQueryValue:[[CatalyzeUser currentUser] usersId]];
    [query setPageNumber:1];
    [query setPageSize:1000];
    [query retrieveAllEntriesInBackgroundWithSuccess:^(NSArray * result){
                                                        [users removeAllObjects];
                                                        for(CatalyzeEntry *entry in result){
                                                            if([[entry content] valueForKey:PF_PEOPLE_USER2] !=nil){
                                                                B_People *people = [[B_People alloc] initWithCaltalyzEntry:entry];
                                                                if(!([people getObjUser2] == nil))
                                                                    [users addObject:[[B_USER alloc] initWithDictionary:(NSDictionary *)[people getObjUser2]]];
                                                            }
                                                        }
                                                        [self setObjects:users];
                                                        [self.tableView reloadData];
                                    }
                                   failure:^(NSDictionary * result, int status, NSError * error){
                                       [ProgressHUD showError:@"Network error."];
                                   }];
//	PFQuery *query = [PFQuery queryWithClassName:PF_PEOPLE_CLASS_NAME];
//	[query whereKey:PF_PEOPLE_USER1 equalTo:[PFUser currentUser]];
//	[query includeKey:PF_PEOPLE_USER2];
//	[query setLimit:1000];
//	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//	{
//		if (error == nil)
//		{
//			[users removeAllObjects];
//			for (PFObject *people in objects)
//			{
//				PFUser *user = people[PF_PEOPLE_USER2];
//				[users addObject:user];
//			}
//			[self setObjects:users];
//			[self.tableView reloadData];
//		}
//		else [ProgressHUD showError:@"Network error."];
//	}];
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
	for (B_USER *object in sorted)
	{
		NSInteger section = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:@selector(getFullName)];
		[sections[section] addObject:object];
	}
}


#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionDone
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *name = fieldName.text;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([name length] == 0)		{ [ProgressHUD showError:@"Group name must be set."]; return; }
	if ([selection count] == 0) { [ProgressHUD showError:@"Please select some users."]; return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------
    CatalyzeUser *user = [CatalyzeUser currentUser];
    [selection addObject:[user usersId]];
    
//	PFUser *user = [PFUser currentUser];
//	[selection addObject:user.objectId];
	//---------------------------------------------------------------------------------------------------------------------------------------------

    CatalyzeEntry * entry = [CatalyzeEntry entryWithClassName:PF_GROUP_CLASS_NAME];
    [[entry content] setObject:user.usersId forKey:PF_GROUP_USER];
    [[entry content] setObject:name forKey:PF_GROUP_NAME];
    [[entry content] setObject:selection forKey:PF_GROUP_MEMBERS];
    [entry createInBackgroundWithSuccess:^(id result){
       	[self dismissViewControllerAnimated:YES completion:nil];
    }failure: ^(NSDictionary * result, int status, NSError * error){
        [ProgressHUD showError:@"Network error."];
    }];
//    PFObject *object = [PFObject objectWithClassName:PF_GROUP_CLASS_NAME];
//	object[PF_GROUP_USER] = [PFUser currentUser];
//	object[PF_GROUP_NAME] = name;
//	object[PF_GROUP_MEMBERS] = selection;
//	[object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//	{
//		if (error == nil)
//		{
//			[self dismissViewControllerAnimated:YES completion:nil];
//		}
//		else [ProgressHUD showError:@"Network error."];
//	}];
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
	B_USER *user = userstemp[indexPath.row];
	cell.textLabel.text = [user getFullName];

    BOOL selected = [selection containsObject:[user getObjectId]];
	cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

	return cell;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSMutableArray *userstemp = sections[indexPath.section];
	B_USER *user = userstemp[indexPath.row];
    BOOL selected = [selection containsObject:[user getObjectId]];
    if (selected) [selection removeObject:[user getObjectId]]; else [selection addObject:[user getObjectId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView reloadData];
}

@end
