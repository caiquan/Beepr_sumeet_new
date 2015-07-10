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

#import <MediaPlayer/MediaPlayer.h>

#import <Firebase/Firebase.h>
#import "IDMPhotoBrowser.h"
#import "RNGridMenu.h"

#import "AppConstant.h"
#import "audio.h"
#import "camera.h"
#import "recent.h"

#import "Incoming.h"
#import "Outgoing.h"

#import "AudioMediaItem.h"
#import "PhotoMediaItem.h"
#import "VideoMediaItem.h"
#import <GoogleMobileAds/GADBannerView.h>
#import "ChatView.h"
#import "StickersView.h"
#import "ProfileView.h"
#import "MapView.h"
#import "NavigationController.h"
#import "B_USER.h"
#import "catalyze.h"
//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatView()
{
	NSString *groupId;

	BOOL initialized;
	int typingCounter;

	Firebase *firebase1;
	Firebase *firebase2;

	NSMutableArray *items;
	NSMutableArray *messages;
	NSMutableDictionary *avatars;

	JSQMessagesBubbleImage *bubbleImageOutgoing;
	JSQMessagesBubbleImage *bubbleImageIncoming;
	JSQMessagesAvatarImage *avatarImageBlank;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ChatView
@synthesize bannerView;
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)groupId_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	groupId = groupId_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Chat";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	items = [[NSMutableArray alloc] init];
	messages = [[NSMutableArray alloc] init];
	avatars = [[NSMutableDictionary alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
    CatalyzeUser *user = [CatalyzeUser currentUser];
    B_USER *bUser = [[B_USER alloc] initWithCatalyzeUser:user];
    
	
    self.senderId = [bUser getObjectId];
    self.senderDisplayName = [bUser getFullName];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
	bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:COLOR_OUTGOING];
	bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:COLOR_INCOMING];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"chat_blank"] diameter:30.0];
    
//    self.bannerView = [[GADBannerView alloc]initWithFrame:CGRectMake(0.0, 0.0, GAD_SIZE_468x60.width, GAD_SIZE_320x50.height)];
//    
//    self.bannerView.delegate = self;
//    
//    self.bannerView.adUnitID = @"ca-app-pub-4886788404179515/8149650981";
//    [self.view addSubview:self.bannerView];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[JSQMessagesCollectionViewCell registerMenuAction:@selector(actionCopy:)];
	[JSQMessagesCollectionViewCell registerMenuAction:@selector(actionDelete:)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIMenuItem *menuItemCopy = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(actionCopy:)];
	UIMenuItem *menuItemDelete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(actionDelete:)];
	[UIMenuController sharedMenuController].menuItems = @[menuItemCopy, menuItemDelete];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	firebase1 = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Message/%@", FIREBASE, groupId]];
	firebase2 = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Typing/%@", FIREBASE, groupId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadMessages];
	[self typingIndicatorLoad];
	[self typingIndicatorSave:@NO];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
	if (self.isMovingFromParentViewController)
	{
		ClearRecentCounter1(groupId);
		[firebase1 removeAllObservers];
		[firebase2 removeAllObservers];
	}
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	initialized = NO;
	self.automaticallyScrollsToMostRecentMessage = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[firebase1 observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot)
	{
		BOOL incoming = [self addMessage:snapshot.value];
		if (incoming) [self messageUpdate:snapshot.value];

		if (initialized)
		{
			if (incoming) [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
			[self finishReceivingMessage];
		}
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[firebase1 observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot)
	{
		[self updateMessage:snapshot.value];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[firebase1 observeEventType:FEventTypeChildRemoved withBlock:^(FDataSnapshot *snapshot)
	{
		[self deleteMessage:snapshot.value];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[firebase1 observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		[self finishReceivingMessage];
		[self scrollToBottomAnimated:NO];
		self.automaticallyScrollsToMostRecentMessage = YES;
		initialized	= YES;
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)addMessage:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Incoming *incoming = [[Incoming alloc] initWith:self.senderId ChatView:self];
	JSQMessage *message = [incoming create:item];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[items addObject:item];
	[messages addObject:message];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [self incoming:message];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateMessage:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	for (int index=0; index<[items count]; index++)
	{
		NSDictionary *temp = items[index];
		if ([item[@"key"] isEqualToString:temp[@"key"]])
		{
			items[index] = item;
			[self.collectionView reloadData];
			break;
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)deleteMessage:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	for (int index=0; index<[items count]; index++)
	{
		NSDictionary *temp = items[index];
		if ([item[@"key"] isEqualToString:temp[@"key"]])
		{
			[items removeObjectAtIndex:index];
			[messages removeObjectAtIndex:index];
			[self.collectionView reloadData];
			break;
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadAvatar:(NSString *)senderId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query setPageNumber:1];
    [query setPageSize:100];
    [query retrieveAllEntriesInBackgroundWithSuccess:^(NSArray * result){
        for(CatalyzeEntry * entry in result){
            B_USER *bUser = [[B_USER alloc] initWithCatalyzeEntry:entry];
            if([[bUser getObjectId] isEqualToString:senderId]){
                if([bUser getProfilePhoto] == (id)[NSNull null])
                    return;
                
                [CatalyzeFileManager retrieveFileFromUser:[bUser getProfilePhoto] usersId:[bUser getObjectId] success:^(NSData *result) {
                    UIImage *image = [UIImage imageWithData:result];
                    avatars[senderId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:image diameter:30.0];
                    [self.collectionView reloadData];
                } failure:^(NSDictionary *result, int status, NSError *error) {
                    NSLog(@"ChatView loadAvatar query error.");
                }];
                
                break;
            }
        }
    } failure:^(NSDictionary *result, int status, NSError *error){
        NSLog(@"ChatView loadAvatar query error.");
    }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)messageSend:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture Audio:(NSString *)audio
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Outgoing *outgoing = [[Outgoing alloc] initWith:groupId View:self.navigationController.view];
	[outgoing send:text Video:video Picture:picture Audio:audio];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[JSQSystemSoundPlayer jsq_playMessageSentSound];
	[self finishSendingMessage];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)messageUpdate:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([item[@"status"] isEqualToString:@"Read"]) return;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[firebase1 childByAppendingPath:item[@"key"]] updateChildValues:@{@"status":@"Read"} withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"ChatView messageUpdate network error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)messageDelete:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *item = items[indexPath.item];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[firebase1 childByAppendingPath:item[@"key"]] removeValueWithCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"ChatView messageDelete network error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)typingIndicatorLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[firebase2 observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot)
	{
        CatalyzeUser *user = [CatalyzeUser currentUser];
        
		if ([user.usersId isEqualToString:snapshot.key] == NO)
		{
			BOOL typing = [snapshot.value boolValue];
			self.showTypingIndicator = typing;
			if (typing) [self scrollToBottomAnimated:YES];
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)typingIndicatorSave:(NSNumber *)typing
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CatalyzeUser *user = [CatalyzeUser currentUser];

	[firebase2 updateChildValues:@{user.usersId:typing} withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"ChatView typingIndicatorSave network error.");
	}];
}

#pragma mark - UITextViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self typingIndicatorStart];
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)typingIndicatorStart
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	typingCounter++;
	[self typingIndicatorSave:@YES];
	[self performSelector:@selector(typingIndicatorStop) withObject:nil afterDelay:2.0];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)typingIndicatorStop
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	typingCounter--;
	if (typingCounter == 0) [self typingIndicatorSave:@NO];
}

#pragma mark - JSQMessagesViewController method overrides

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)name date:(NSDate *)date
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self messageSend:text Video:nil Picture:nil Audio:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressAccessoryButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self actionAttach];
}

#pragma mark - JSQMessages CollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return messages[indexPath.item];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
			 messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self outgoing:messages[indexPath.item]])
	{
		return bubbleImageOutgoing;
	}
	else return bubbleImageIncoming;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
					avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if (avatars[message.senderId] == nil)
	{
		[self loadAvatar:message.senderId];
		return avatarImageBlank;
	}
	else return avatars[message.senderId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		JSQMessage *message = messages[indexPath.item];
		return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
	}
	else return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([self incoming:message])
	{
		if (indexPath.item > 0)
		{
			JSQMessage *previous = messages[indexPath.item-1];
			if ([previous.senderId isEqualToString:message.senderId])
			{
				return nil;
			}
		}
		return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
	}
	else return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self outgoing:messages[indexPath.item]])
	{
		NSDictionary *item = items[indexPath.item];
		return [[NSAttributedString alloc] initWithString:item[@"status"]];
	}
	else return nil;
}

#pragma mark - UICollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [messages count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

	if ([self outgoing:messages[indexPath.item]])
	{
		cell.textView.textColor = [UIColor whiteColor];
	}
	else
	{
		cell.textView.textColor = [UIColor blackColor];
	}
	return cell;
}

#pragma mark - UICollectionView Delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath
			withSender:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (action == @selector(actionCopy:))
	{
		NSDictionary *item = items[indexPath.item];
		if ([item[@"type"] isEqualToString:@"text"]) return YES;
	}
	if (action == @selector(actionDelete:))
	{
		JSQMessage *message = messages[indexPath.item];
		if ([self outgoing:message]) return YES;
	}
	return NO;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath
			withSender:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (action == @selector(actionCopy:))		[self actionCopy:indexPath];
	if (action == @selector(actionDelete:))		[self actionDelete:indexPath];
}

#pragma mark - JSQMessages collection view flow layout delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	else return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([self incoming:message])
	{
		if (indexPath.item > 0)
		{
			JSQMessage *previous = messages[indexPath.item-1];
			if ([previous.senderId isEqualToString:message.senderId])
			{
				return 0;
			}
		}
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	else return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self outgoing:messages[indexPath.item]])
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	else return 0;
}

#pragma mark - Responding to collection view tap events

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView
				header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapLoadEarlierMessagesButton");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
		   atIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([self incoming:message])
	{
		ProfileView *profileView = [[ProfileView alloc] initWith:message.senderId User:nil];
		[self.navigationController pushViewController:profileView animated:YES];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (message.isMediaMessage)
	{
		if ([message.media isKindOfClass:[PhotoMediaItem class]])
		{
			PhotoMediaItem *mediaItem = (PhotoMediaItem *)message.media;
			NSArray *photos = [IDMPhoto photosWithImages:@[mediaItem.image]];
			IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
			[self presentViewController:browser animated:YES completion:nil];
		}
		if ([message.media isKindOfClass:[VideoMediaItem class]])
		{
			VideoMediaItem *mediaItem = (VideoMediaItem *)message.media;
			MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:mediaItem.fileURL];
			[self presentMoviePlayerViewControllerAnimated:moviePlayer];
			[moviePlayer.moviePlayer play];
		}
		if ([message.media isKindOfClass:[AudioMediaItem class]])
		{
			AudioMediaItem *mediaItem = (AudioMediaItem *)message.media;
			MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:mediaItem.fileURL];
			[self presentMoviePlayerViewControllerAnimated:moviePlayer];
			[moviePlayer.moviePlayer play];
		}
		if ([message.media isKindOfClass:[JSQLocationMediaItem class]])
		{
			JSQLocationMediaItem *mediaItem = (JSQLocationMediaItem *)message.media;
			MapView *mapView = [[MapView alloc] initWith:mediaItem.location];
			NavigationController *navController = [[NavigationController alloc] initWithRootViewController:mapView];
			[self presentViewController:navController animated:YES completion:nil];
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapCellAtIndexPath %@", NSStringFromCGPoint(touchLocation));
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAttach
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
	NSArray *menuItems = @[[[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_camera"] title:@"Camera"],
						   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_audio"] title:@"Audio"],
						   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_pictures"] title:@"Pictures"],
						   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_videos"] title:@"Videos"],
						   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_location"] title:@"Location"],
						   [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_stickers"] title:@"Stickers"]];
	RNGridMenu *gridMenu = [[RNGridMenu alloc] initWithItems:menuItems];
	gridMenu.delegate = self;
	[gridMenu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionStickers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	StickersView *stickersView = [[StickersView alloc] init];
	stickersView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:stickersView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionDelete:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self messageDelete:indexPath];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCopy:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *item = items[indexPath.item];
	[[UIPasteboard generalPasteboard] setString:item[@"text"]];
}

#pragma mark - RNGridMenuDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[gridMenu dismissAnimated:NO];
	if ([item.title isEqualToString:@"Camera"])		PresentMultiCamera(self, YES);
	if ([item.title isEqualToString:@"Audio"])		PresentAudioRecorder(self);
	if ([item.title isEqualToString:@"Pictures"])	PresentPhotoLibrary(self, YES);
	if ([item.title isEqualToString:@"Videos"])		PresentVideoLibrary(self, YES);
	if ([item.title isEqualToString:@"Location"])	[self messageSend:nil Video:nil Picture:nil Audio:nil];
	if ([item.title isEqualToString:@"Stickers"])	[self actionStickers];
}

#pragma mark - UIImagePickerControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSURL *video = info[UIImagePickerControllerMediaURL];
	UIImage *picture = info[UIImagePickerControllerEditedImage];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self messageSend:nil Video:video Picture:picture Audio:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IQAudioRecorderControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)audioRecorderController:(IQAudioRecorderController *)controller didFinishWithAudioAtPath:(NSString *)path
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self messageSend:nil Video:nil Picture:nil Audio:path];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)audioRecorderControllerDidCancel:(IQAudioRecorderController *)controller
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - StickersDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectSticker:(NSString *)sticker
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIImage *picture = [UIImage imageNamed:sticker];
	[self messageSend:nil Video:nil Picture:picture Audio:nil];
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)incoming:(JSQMessage *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return ([message.senderId isEqualToString:self.senderId] == NO);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)outgoing:(JSQMessage *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return ([message.senderId isEqualToString:self.senderId] == YES);
}
-(void) viewWillAppear:(BOOL)animated
{
    [self adBanner];
}

-(void)adBanner
{
    self.bannerView.adUnitID = @"ca-app-pub-4886788404179515/8149650981";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
}


@end
