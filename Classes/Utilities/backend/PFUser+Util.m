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

#import "PFUser+Util.h"

@implementation CatalyzeEntry (Util)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)fullname
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[self content] valueForKey:PF_USER_FULLNAME];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)isEqualTo:(CatalyzeEntry *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return [[[self content] valueForKey:PF_USER_OBJECTID] isEqualToString:[[user content] valueForKey:PF_USER_OBJECTID]];
//    return [[[self content] valueForKey:PF_USER_OBJECTID isEqualToString:user.objectId] ];
}

@end
