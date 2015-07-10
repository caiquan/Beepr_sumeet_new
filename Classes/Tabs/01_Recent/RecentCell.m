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
#import "converter.h"

#import "RecentCell.h"
//-------------------------------------------------------------------------------------------------------------------------------------------------
#import "Catalyze.h"
#import "UIImageView+AFNetworking.h"
#import "B_USER.h"
//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RecentCell()
{
	NSDictionary *recent;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet UILabel *labelLastMessage;
@property (strong, nonatomic) IBOutlet UILabel *labelElapsed;
@property (strong, nonatomic) IBOutlet UILabel *labelCounter;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RecentCell

@synthesize imageUser;
@synthesize labelDescription, labelLastMessage;
@synthesize labelElapsed, labelCounter;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)bindData:(NSDictionary *)recent_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	recent = recent_;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
	imageUser.layer.masksToBounds = YES;
    
//    //---------------------------------------------------------------------------------------------------------------------------------------------
//    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
//    [query whereKey:PF_USER_OBJECTID equalTo:recent[@"profileId"]];
//    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//     {
//         if (error == nil)
//         {
//             PFUser *user = [objects firstObject];
//             [imageUser setFile:user[PF_USER_PICTURE]];
//             [imageUser loadInBackground];
//         }
//     }];
//    //---------------------------------------------------------------------------------------------------------------------------------------------
	//---------------------------------------------------------------------------------------------------------------------------------------------
    
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query setQueryValue:recent[@"userId"]];
    [query setQueryField:PF_USER_OBJECTID];
    [query setPageNumber:1];
    [query setPageSize:100];
    [query retrieveInBackgroundWithSuccess:^(NSArray *result) {
        B_USER *bUser = [[B_USER alloc] initWithCatalyzeEntry:(CatalyzeEntry *)[result firstObject]];
        if([bUser getProfilePhoto] == (id)[NSNull null])
            return ;

        [CatalyzeFileManager retrieveFileFromUser:[bUser getProfilePhoto] usersId:[bUser getObjectId] success:^(NSData *result) {

            [imageUser setImage:[[UIImage alloc] initWithData:result]];
        } failure:^(NSDictionary *result, int status, NSError *error) {
            NSLog(@"Getting image failure =====================> at recent Cell");
        }];
    } failure:^(NSDictionary *result, int status, NSError *error) {
            NSLog(@"Getting user info failure =====================> at recent Cell");
    }];
    
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelDescription.text = recent[@"description"];
	labelLastMessage.text = recent[@"lastMessage"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDate *date = String2Date(recent[@"date"]);
	NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:date];
	labelElapsed.text = TimeElapsed(seconds);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	int counter = [recent[@"counter"] intValue];
	labelCounter.text = (counter == 0) ? @"" : [NSString stringWithFormat:@"%d new", counter];
}

@end
