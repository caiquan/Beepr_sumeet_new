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

#import "AppConstant.h"
#import "people.h"
#import "B_USER.h"
#import "B_People.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void PeopleSave(CatalyzeUser *user1, CatalyzeUser *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_PEOPLE_CLASS_NAME];
    [query setPageSize:100];
    [query setPageNumber:1];
    [query setQueryField:PF_PEOPLE_USER1];
    [query setQueryValue:user1.usersId];
    [query setQueryField:PF_PEOPLE_USER2];
    [query setQueryValue:user2.usersId];
    [query retrieveInBackgroundWithSuccess:^(NSArray* result){
        if([result count] == 0){
        
            CatalyzeEntry *entry = [CatalyzeEntry entryWithClassName:PF_PEOPLE_CLASS_NAME];
            [[entry content] setValue:user1.usersId forKey:PF_PEOPLE_USER1];
            [[entry content] setValue:user2.usersId forKey:PF_PEOPLE_USER2];
            [entry saveInBackgroundWithSuccess:^(id result){
                
            } failure:^(NSDictionary* result, int status , NSError* error){
                NSLog(@"PeopleSave save error.");
            }];
        
        }
    }failure:^(NSDictionary *result, int status, NSError* error){
        NSLog(@"PeopleSave query error.");
    }];
    
//	PFQuery *query = [PFQuery queryWithClassName:PF_PEOPLE_CLASS_NAME];
//	[query whereKey:PF_PEOPLE_USER1 equalTo:user1];
//	[query whereKey:PF_PEOPLE_USER2 equalTo:user2];
//	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//	{
//		if (error == nil)
//		{
//			if ([objects count] == 0)
//			{
//				PFObject *object = [PFObject objectWithClassName:PF_PEOPLE_CLASS_NAME];
//				object[PF_PEOPLE_USER1] = user1;
//				object[PF_PEOPLE_USER2] = user2;
//				[object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//				{
//					if (error != nil) NSLog(@"PeopleSave save error.");
//				}];
//			}
//		}
//		else NSLog(@"PeopleSave query error.");
//	}];
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
void PeopleSaveWithBUser(B_USER *user1, B_USER *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_PEOPLE_CLASS_NAME];
    [query setPageSize:1000];
    [query setPageNumber:1];
    [query setQueryField:PF_PEOPLE_USER1];
    [query setQueryValue:[user1 getObjectId]];

    [query retrieveAllEntriesInBackgroundWithSuccess:^(NSArray* result){
        BOOL flag = NO;
        
        for(CatalyzeEntry * entry in result){
            B_People * people = [[B_People alloc] initWithCaltalyzEntry:entry];
            if([[people getUser2] isEqualToString:[user2 getObjectId]])
                flag = YES;
                
        }
        if(flag == NO){
            CatalyzeEntry *entry = [CatalyzeEntry entryWithClassName:PF_PEOPLE_CLASS_NAME];
            
            [[entry content] setValue:[user1 getObjectId] forKey:PF_PEOPLE_USER1];
            [[entry content] setValue:[user2 getObjectId] forKey:PF_PEOPLE_USER2];
            [[entry content] setValue:[[user1 getEntry] content] forKey:@"objUser1"];
            [[entry content] setValue:[[user2 getEntry] content]forKey:@"objUser2"];
            [[entry content] setValue:[user1 getFullName] forKey:@"nameUser1"];
            [[entry content] setValue:[user2 getFullName] forKey:@"nameUser2"];
            
            [entry createInBackgroundWithSuccess:^(id result){
                
            } failure:^(NSDictionary* result, int status , NSError* error){
                NSLog(@"PeopleSave save error.");
            }];
            
        }
    }failure:^(NSDictionary *result, int status, NSError* error){
        NSLog(@"PeopleSave query error.");
    }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void PeopleDelete(B_USER *user1, B_USER *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_PEOPLE_CLASS_NAME];
    [query setPageSize:1000];
    [query setPageNumber:1];
    [query setQueryField:PF_PEOPLE_USER1];
    [query setQueryValue:[user1 getObjectId]];
    [query setQueryField:PF_PEOPLE_USER2];
    [query setQueryValue:[user2 getObjectId]];
    [query retrieveInBackgroundWithSuccess:^(NSArray* result){
        for(CatalyzeEntry* entry in result){
            [entry deleteInBackgroundWithSuccess:^(id result){
            } failure:^(NSDictionary * result, int status, NSError* error){
                NSLog(@"PeopleDelete delete error.");
            }];
        }
    }failure:^(NSDictionary* result, int status, NSError* error){
        NSLog(@"PeopleDelete query error.");
    }];
//	PFQuery *query = [PFQuery queryWithClassName:PF_PEOPLE_CLASS_NAME];
//	[query whereKey:PF_PEOPLE_USER1 equalTo:user1];
//	[query whereKey:PF_PEOPLE_USER2 equalTo:user2];
//	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//	{
//		if (error == nil)
//		{
//			for (PFObject *people in objects)
//			{
//				[people deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//				{
//					if (error != nil) NSLog(@"PeopleDelete delete error.");
//				}];
//			}
//		}
//		else NSLog(@"PeopleDelete query error.");
//	}];
}
