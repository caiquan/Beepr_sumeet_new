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
#import <Firebase/Firebase.h>

#import "AppConstant.h"
#import "AFNetworking.h"

#import "push.h"
#import "catalyze.h"

////-------------------------------------------------------------------------------------------------------------------------------------------------
//void ParsePushUserAssign(void)
////-------------------------------------------------------------------------------------------------------------------------------------------------
//{
//	PFInstallation *installation = [PFInstallation currentInstallation];
//	installation[PF_INSTALLATION_USER] = [PFUser currentUser];
//	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//	{
//		if (error != nil)
//		{
//			NSLog(@"ParsePushUserAssign save error.");
//		}
//	}];
//}
//
////-------------------------------------------------------------------------------------------------------------------------------------------------
//void ParsePushUserResign(void)
////-------------------------------------------------------------------------------------------------------------------------------------------------
//{
//	PFInstallation *installation = [PFInstallation currentInstallation];
//	[installation removeObjectForKey:PF_INSTALLATION_USER];
//	[installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//	{
//		if (error != nil)
//		{
//			NSLog(@"ParsePushUserResign save error.");
//		}
//	}];
//}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void SendPushNotification1(NSString *groupId, NSString *text)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		if (snapshot.value != [NSNull null])
		{
			NSArray *recents = [snapshot.value allValues];
			NSDictionary *recent = [recents firstObject];
			if (recent != nil)
			{
				SendPushNotification2(recent[@"members"], text);
			}
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void SendPushNotification2(NSArray *members, NSString *text)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeUser *user = [CatalyzeUser currentUser];
    
	NSString *message = [NSString stringWithFormat:@"%@: %@", user.username, text];
    
    {
        AFHTTPRequestOperationManager *client = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://go.urbanairship.com"]];
        client.requestSerializer = [AFJSONRequestSerializer serializer];
        [client.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        client.responseSerializer = [AFHTTPResponseSerializer serializer];
        [client.operationQueue setMaxConcurrentOperationCount:1];
        
        NSDictionary *ua = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AirshipConfig" ofType:@"plist"]];
        [client.requestSerializer setAuthorizationHeaderFieldWithUsername:[ua valueForKey:@"developmentAppKey"] password:[ua valueForKey:@"developmentMasterSecret"]];
        
        NSMutableDictionary *notification = [NSMutableDictionary dictionary];
        [notification setValue:@"all" forKey:@"device_types"];
//        [notification setValue:@{@"alert":[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername]} forKey:@"notification"];
        [notification setValue:@{@"alert":message} forKey:@"notification"];
        [notification setValue:@[user.username] forKey:@"aliases"];
        
        [client POST:@"/api/push/" parameters:notification success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"successfully sent push notification");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error: %@", error);
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not notify the recipient, they must refresh manually" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }];

    }
    
	
//	PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
//	[query whereKey:PF_USER_OBJECTID containedIn:members];
//	[query whereKey:PF_USER_OBJECTID notEqualTo:user.objectId];
//	[query setLimit:1000];
//
//	PFQuery *queryInstallation = [PFInstallation query];
//	[queryInstallation whereKey:PF_INSTALLATION_USER matchesQuery:query];
//
//	PFPush *push = [[PFPush alloc] init];
//	[push setQuery:queryInstallation];
//	[push setMessage:message];
//	[push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//	{
//		if (error != nil)
//		{
//			NSLog(@"SendPushNotification2 send error.");
//		}
//	}];
}
