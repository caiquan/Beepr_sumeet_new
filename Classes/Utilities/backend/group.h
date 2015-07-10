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

#include "catalyze.h"
#import "B_USER.h"
#import "B_Group.h"
//-------------------------------------------------------------------------------------------------------------------------------------------------
void			RemoveGroupMembers		( B_USER *user1, B_USER *user2);

//-------------------------------------------------------------------------------------------------------------------------------------------------
void			RemoveGroupMember		(B_Group *group, B_USER *user);
void			RemoveGroupItem			(CatalyzeEntry *group);
