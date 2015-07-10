
#import "AppDelegate.h"

#import "StickersView.h"
#import "StickersCell.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface StickersView()

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation StickersView

@synthesize delegate;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Stickers";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
																						  action:@selector(actionCancel)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.collectionView registerNib:[UINib nibWithNibName:@"StickersCell" bundle:nil] forCellWithReuseIdentifier:@"StickersCell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
	self.collectionView.frame = CGRectMake(0, 0, app.window.frame.size.width, app.window.frame.size.height-64);
	//---------------------------------------------------------------------------------------------------------------------------------------------
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 78;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	StickersCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"StickersCell" forIndexPath:indexPath];
	[cell bindData:indexPath.item];
	return cell;
}

#pragma mark - UICollectionViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[collectionView deselectItemAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *sticker = [NSString stringWithFormat:@"stickersend%02d", (int) indexPath.item+1];
	if (delegate != nil) [delegate didSelectSticker:sticker];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
