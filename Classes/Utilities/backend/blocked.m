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

#import "AppConstant.h"
#import "group.h"
#import "people.h"
#import "recent.h"

#import "blocked.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
#import "catalyze.h"
//-------------------------------------------------------------------------------------------------------------------------------------------------

void BlockUser(B_USER *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CatalyzeUser *user = [CatalyzeUser currentUser];
    B_USER *user1 = [[B_USER alloc] initWithCatalyzeUser:user];
    
	//---------------------------------------------------------------------------------------------------------------------------------------------
	BlockUserOne(user1, user2);
	BlockUserOne(user2, user1);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	RemoveGroupMembers(user1, user2);
	RemoveGroupMembers(user2, user1);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PeopleDelete(user1, user2);
	PeopleDelete(user2, user1);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	DeleteRecentItems(user1, user2);
	DeleteRecentItems(user2, user1);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void BlockUserOne(B_USER *user1, B_USER *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
    [query setQueryField:PF_BLOCKED_USER];
    [query setQueryValue:[CatalyzeUser currentUser]];
    [query setQueryField:PF_BLOCKED_USER1];
    [query setQueryValue:user1];
    [query setQueryField:PF_BLOCKED_USER2];
    [query setQueryValue:user2];
    [query setPageSize:100];
    [query setPageNumber:1];
    
    [query retrieveInBackgroundWithSuccess:^(NSArray *result) {
        if([result count] == 0){
            CatalyzeEntry* entry = [CatalyzeEntry entryWithClassName:PF_BLOCKED_CLASS_NAME];
            [[entry content] setValue:[CatalyzeUser currentUser] forKey:PF_BLOCKED_USER];
            [[entry content] setValue:user1 forKey:PF_BLOCKED_USER1];
            [[entry content] setValue:user2 forKey:PF_BLOCKED_USER2];
            
            [entry saveInBackgroundWithSuccess:^(id result){
                
            } failure:^(NSDictionary *result , int status, NSError *error){
                NSLog(@"BlockUserOne save error.");
            }];
            
        }
    } failure:^(NSDictionary *result, int status, NSError *error) {
       NSLog(@"BlockUserOne query error.");
    }];
    
//	PFQuery *query = [PFQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
//	[query whereKey:PF_BLOCKED_USER equalTo:[PFUser currentUser]];
//	[query whereKey:PF_BLOCKED_USER1 equalTo:user1];
//	[query whereKey:PF_BLOCKED_USER2 equalTo:user2];
//	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//	{
//		if (error == nil)
//		{
//			if ([objects count] == 0)
//			{
//				PFObject *object = [PFObject objectWithClassName:PF_BLOCKED_CLASS_NAME];
//				object[PF_BLOCKED_USER] = [PFUser currentUser];
//				object[PF_BLOCKED_USER1] = user1;
//				object[PF_BLOCKED_USER2] = user2;
//				object[PF_BLOCKED_USERID2] = user2.objectId;
//				[object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//				{
//					if (error != nil) NSLog(@"BlockUserOne save error.");
//				}];
//			}
//		}
//		else NSLog(@"BlockUserOne query error.");
//	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void UnblockUser(CatalyzeUser *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CatalyzeUser *user1 = [CatalyzeUser currentUser];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UnblockUserOne(user1, user2);
	UnblockUserOne(user2, user1);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void UnblockUserOne(CatalyzeUser *user1, CatalyzeUser *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
    [query setQueryField:PF_BLOCKED_USER];
    [query setQueryValue:[CatalyzeUser currentUser]];
    [query setQueryField:PF_BLOCKED_USER1];
    [query setQueryValue:user1];
    [query setQueryField:PF_BLOCKED_USER2];
    [query setQueryValue:user2];
    [query setPageSize:100];
    [query setPageNumber:1];
    [query retrieveInBackgroundWithSuccess:^(NSArray *result){
        for(CatalyzeEntry *entry in result){
            [entry deleteInBackground];
        }
    } failure:^(NSDictionary *result, int status, NSError *error){
        NSLog(@"UnblockUserOne query error.");        
    }];
//	PFQuery *query = [PFQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
//	[query whereKey:PF_BLOCKED_USER equalTo:[PFUser currentUser]];
//	[query whereKey:PF_BLOCKED_USER1 equalTo:user1];
//	[query whereKey:PF_BLOCKED_USER2 equalTo:user2];
//	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//	{
//		if (error == nil)
//		{
//			for (PFObject *blocked in objects)
//			{
//				[blocked deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//				{
//					if (error != nil) NSLog(@"UnblockUserOne delete error.");
//				}];
//			}
//		}
//		else NSLog(@"UnblockUserOne query error.");
//	}];
}
