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
#import "ProgressHUD.h"

#import "AppConstant.h"

#import "report.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ReportUser(B_USER *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CatalyzeUser *user1 = [CatalyzeUser currentUser];

	CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_REPORT_CLASS_NAME];
    [query setQueryField:PF_REPORT_USER1];
    [query setQueryValue:user1.usersId];
    [query setQueryField:PF_REPORT_USER2];
    [query setQueryValue:[user2 getObjectId]];
    [query setPageNumber:1];
    [query setPageSize:1000];
    [query retrieveInBackgroundWithSuccess:^(NSArray *result){
        if([result count] == 0){
            CatalyzeEntry *entry = [CatalyzeEntry entryWithClassName:PF_REPORT_CLASS_NAME];
            [entry setValue:user1 forKey:PF_REPORT_USER1];
            [entry setValue:user2 forKey:PF_REPORT_USER2];
            [entry saveInBackgroundWithSuccess:^(id result){
                		[ProgressHUD showSuccess:@"User reported."];
            }failure:^(NSDictionary *result, int status , NSError *error){
                [ProgressHUD showError:@"User already reported."];
            }];
        }
    }failure:^(NSDictionary *result, int status, NSError * error){
        NSLog(@"ReportUser query error.");
    }];
//	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//	{
//		if (error == nil)
//		{
//			if ([objects count] == 0)
//			{
//				PFObject *object = [PFObject objectWithClassName:PF_REPORT_CLASS_NAME];
//				object[PF_REPORT_USER1] = user1;
//				object[PF_REPORT_USER2] = user2;
//				[object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//				{
//					if (error == nil)
//					{
//						[ProgressHUD showSuccess:@"User reported."];
//					}
//					else NSLog(@"ReportUser save error.");
//				}];
//			}
//			else [ProgressHUD showError:@"User already reported."];
//		}
//		else NSLog(@"ReportUser query error.");
//	}];
}
