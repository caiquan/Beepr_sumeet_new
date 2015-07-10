//
//  MessageTableViewCell.h
//  HipaaGram
//
//  Created by ault on 2/18/15.
//  Copyright (c) 2015 Catalyze Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"

@interface MessageTableViewCell : UITableViewCell

- (void)initializeWithMessage:(Message *)message sender:(BOOL)sender;

@end
