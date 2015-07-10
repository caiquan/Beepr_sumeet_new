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
//-------------------------------------------------------------------------------------------------------------------------------------------------
#import "catalyze.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void RemoveGroupMembers(B_USER *user1, B_USER *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_GROUP_CLASS_NAME];
    [query setPageNumber:1];
    [query setPageSize:100];
    [query retrieveAllEntriesInBackgroundWithSuccess:^(NSArray *result) {
        for (CatalyzeEntry *entry in result) {
            if ([[[entry content] valueForKey:PF_GROUP_USER] isEqualToString:[user1 getFullName]]
                  && [[[entry content] valueForKey:PF_GROUP_USER] isEqualToString:[user2 getObjectId]]) {
                RemoveGroupMember([[B_Group alloc] initWithEntry:entry], user2);
            }
        }
    } failure:^(NSDictionary *result, int status, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not fetch the contacts: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
    
//	PFQuery *query = [PFQuery queryWithClassName:PF_GROUP_CLASS_NAME];
//	[query whereKey:PF_GROUP_USER equalTo:user1];
//	[query whereKey:PF_GROUP_MEMBERS equalTo:user2.objectId];
//	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//	{
//		if (error == nil)
//		{
//			for (PFObject *group in objects)
//			{
//				RemoveGroupMember(group, user2);
//			}
//		}
//		else NSLog(@"RemoveGroupMembers query error.");
//	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void RemoveGroupMember(B_Group *group, B_USER *user)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSArray* _group = [group getMemebers];
    
    if([_group containsObject: [user getObjectId]])
	{
        CatalyzeEntry * entry = [group getEntry];
        
        [_group delete:[user getObjectId]];
        [[entry content] setValue:_group forKey:PF_GROUP_MEMBERS];
        
        [entry saveInBackgroundWithSuccess:^(id result) {

        } failure:^(NSDictionary *result, int status, NSError *error) {
            NSLog(@"RemoveGroupMember save error.");
        }];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void RemoveGroupItem(CatalyzeEntry *group)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [group deleteInBackground];
//	[group deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//	{
//		if (error != nil) NSLog(@"RemoveGroupItem delete error.");
//	}];
}
