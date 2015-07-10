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

#import <Firebase/Firebase.h>
#import "PFUser+Util.h"
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "converter.h"

#import "recent.h"

#import "catalyze.h"
#import "B_USER.h"
#import "B_Group.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* StartPrivateChat(B_USER *user1, B_USER *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *id1 = [user1 getObjectId];
    NSString *id2 = [user2 getObjectId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *groupId = ([id1 compare:id2] < 0) ? [NSString stringWithFormat:@"%@%@", id1, id2] : [NSString stringWithFormat:@"%@%@", id2, id1];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *members = @[[user1 getObjectId], [user2 getObjectId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	CreateRecentItem1(user1, groupId, members, [user2 getFullName], user2);
	CreateRecentItem1(user2, groupId, members, [user1 getFullName], user1);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return groupId;
}

NSString* StartPrivateChatWithBuser(B_USER *user1, B_USER *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSString *id1 = [user1 getObjectId];
    NSString *id2 = [user2 getObjectId];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSString *groupId = ([id1 compare:id2] < 0) ? [NSString stringWithFormat:@"%@%@", id1, id2] : [NSString stringWithFormat:@"%@%@", id2, id1];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSArray *members = @[[user1 getObjectId], [user2 getObjectId]];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    
    CreateRecentItem1WithBUser(user1, groupId, members, [user2 getFullName], user2);
    CreateRecentItem1WithBUser(user2, groupId, members, [user1 getFullName], user1);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    return groupId;
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* StartMultipleChat(NSMutableArray *users)//NSMutalbeArray with B_User
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *groupId = @"";
	NSString *description = @"";

    CatalyzeUser *currentUser = [CatalyzeUser currentUser];
    B_USER *bUser = [[B_USER alloc] initWithCatalyzeUser:currentUser];
    
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[users addObject:bUser];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSMutableArray *userIds = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (B_USER *user in users)
	{
        [userIds addObject:[user getObjectId]];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *sorted = [userIds sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (NSString *userId in sorted)
	{
		groupId = [groupId stringByAppendingString:userId];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (B_USER *user in users)
	{
		if ([description length] != 0) description = [description stringByAppendingString:@" & "];
        description = [description stringByAppendingString:[user getFullName]];//
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (B_USER *user in users)
	{
		CreateRecentItem1WithBUser(user, groupId, userIds, description,bUser);
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return groupId;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void StartGroupChat(CatalyzeEntry *group, NSMutableArray *users)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeUser *currentUser = [CatalyzeUser currentUser];
    B_Group *bGroup = [[B_Group alloc] initWithEntry:group];
    B_USER *bUser = [[B_USER alloc] initWithCatalyzeUser:currentUser];

	for (B_USER *user in users)
	{
		CreateRecentItem1WithBUser(user, [bGroup getObjectId], [bGroup getMemebers], [bGroup getName], bUser);
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void CreateRecentItem1(B_USER *user, NSString *groupId, NSArray *members, NSString *description, B_USER *profile)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		BOOL create = YES;
		if (snapshot.value != [NSNull null])
		{
			for (NSDictionary *recent in [snapshot.value allValues])
			{
                if ([recent[@"userId"] isEqualToString:[user getObjectId]]) create = NO;
			}
		}
		if (create) CreateRecentItem2(user, groupId, members, description, profile);
	}];
}

void CreateRecentItem1WithBUser(B_USER *user, NSString *groupId, NSArray *members, NSString *description, B_USER *profile)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
    FQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
    [query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
     {
         BOOL create = YES;
         if (snapshot.value != [NSNull null])
         {
             for (NSDictionary *recent in [snapshot.value allValues])
             {
                 if ([recent[@"userId"] isEqualToString:[user getObjectId]]) create = NO;
             }
         }
//         if (create) CreateRecentItem2(user, groupId, members, description, profile);
         if (create) CreateRecentItem2WithBUser(user, groupId, members, description, profile);
     }];
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
void CreateRecentItem2(B_USER *user, NSString *groupId, NSArray *members, NSString *description, B_USER *profile)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	Firebase *reference = [firebase childByAutoId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *recentId = reference.key;
	CatalyzeUser *lastUser = [CatalyzeUser currentUser];
	NSString *date = Date2String([NSDate date]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDictionary *recent = @{@"recentId":recentId, @"userId":[user getObjectId], @"groupId":groupId, @"members":members, @"description":description,
								@"lastUser":lastUser.usersId, @"lastMessage":@"", @"counter":@0, @"date":date, @"profileId":[profile getObjectId]};
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[reference setValue:recent withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"CreateRecentItem2 save error.");
	}];
}

void CreateRecentItem2WithBUser(B_USER *user, NSString *groupId, NSArray *members, NSString *description, B_USER *profile)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
    Firebase *reference = [firebase childByAutoId];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSString *recentId = reference.key;
    CatalyzeUser *lastUser = [CatalyzeUser currentUser];
    NSString *date = Date2String([NSDate date]);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSDictionary *recent = @{@"recentId":recentId, @"userId":[user getObjectId], @"groupId":groupId, @"members":members, @"description":description,
                             @"lastUser":lastUser.usersId, @"lastMessage":@"", @"counter":@0, @"date":date, @"profileId":[profile getObjectId]};
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [reference setValue:recent withCompletionBlock:^(NSError *error, Firebase *ref)
     {
         if (error != nil) NSLog(@"CreateRecentItem2 save error.");
     }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void UpdateRecentCounter1(NSString *groupId, NSInteger amount, NSString *lastMessage)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		if (snapshot.value != [NSNull null])
		{
			for (NSDictionary *recent in [snapshot.value allValues])
			{
				UpdateRecentCounter2(recent, amount, lastMessage);
			}
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void UpdateRecentCounter2(NSDictionary *recent, NSInteger amount, NSString *lastMessage)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CatalyzeUser *user = [CatalyzeUser currentUser];
	NSString *date = Date2String([NSDate date]);
	NSInteger counter = [recent[@"counter"] integerValue];
	if ([recent[@"userId"] isEqualToString:user.usersId] == NO) counter += amount;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent/%@", FIREBASE, recent[@"recentId"]]];
	NSDictionary *values = @{@"lastUser":user.usersId, @"lastMessage":lastMessage, @"counter":@(counter), @"date":date};
	[firebase updateChildValues:values withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		[ProgressHUD dismiss];
		if (error != nil) NSLog(@"UpdateRecentCounter2 save error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ClearRecentCounter1(NSString *groupId)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		if (snapshot.value != [NSNull null])
		{
			CatalyzeUser *user = [CatalyzeUser currentUser];
			for (NSDictionary *recent in [snapshot.value allValues])
			{
				if ([recent[@"userId"] isEqualToString:user.usersId])
				{
					ClearRecentCounter2(recent);
				}
			}
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ClearRecentCounter2(NSDictionary *recent)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent/%@", FIREBASE, recent[@"recentId"]]];
	[firebase updateChildValues:@{@"counter":@0} withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"ClearRecentCounter2 save error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void DeleteRecentItems(B_USER *user1, B_USER *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"userId"] queryEqualToValue:[user1 getObjectId]];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		if (snapshot.value != [NSNull null])
		{
			for (NSDictionary *recent in [snapshot.value allValues])
			{
				if ([recent[@"members"] containsObject:[user2 getObjectId]])
				{
					DeleteRecentItem(recent);
				}
			}
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void DeleteRecentItem(NSDictionary *recent)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent/%@", FIREBASE, recent[@"recentId"]]];
	[firebase removeValueWithCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"DeleteRecentItem delete error.");
	}];
}
