//
//  MessageTableViewCell.m
//  HipaaGram
//
//  Created by ault on 2/18/15.
//  Copyright (c) 2015 Catalyze Inc. All rights reserved.
//

#import "MessageTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface MessageTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *lblTimestamp;
@property (weak, nonatomic) IBOutlet UITextView *txtMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblFrom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;

@end

@implementation MessageTableViewCell

- (void)awakeFromNib {
    _txtMessage.layer.cornerRadius = 5;
}

- (void)initializeWithMessage:(Message *)message sender:(BOOL)sender {
    _txtMessage.text = [message text];
    _lblFrom.text = [message sender];
    
    NSDate *timestamp = [message date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy, h:mm.ss a"];
    _lblTimestamp.text = [format stringFromDate:timestamp];
    
    CGFloat usableWidth = [UIScreen mainScreen].bounds.size.width - 16.0f; // 8 for each side padding
    CGFloat idealWidth = usableWidth * 0.85; // ideally we want 85% of the screen width for aesthetics
    // sizeThatFits: doesn't work with UITextViews at all
    CGSize idealSize = [self labelSizeThatFits:CGSizeMake(idealWidth, MAXFLOAT) withText:[message text]];
    CGFloat bigMargin = usableWidth - idealWidth;//idealSize.width;
    CGFloat padding = 0.0; // the auto layout alignment uses an offset from the default
    if (sender) {
        _txtMessage.textAlignment = NSTextAlignmentRight;
        _lblFrom.textAlignment = NSTextAlignmentRight;
        _txtMessage.textColor = [UIColor whiteColor];
        _txtMessage.backgroundColor = [UIColor colorWithRed:51.0/255.0f green:181.0/255.0f blue:229.0/255.0f alpha:1.0f];
        _leftConstraint.constant = bigMargin;
        _rightConstraint.constant = padding;
    } else {
        _txtMessage.textAlignment = NSTextAlignmentLeft;
        _lblFrom.textAlignment = NSTextAlignmentLeft;
        _txtMessage.textColor = [UIColor blackColor];
        _txtMessage.backgroundColor = [UIColor colorWithRed:225.0/255.0f green:225.0/255.0f blue:225.0/255.0f alpha:1.0f];
        _leftConstraint.constant = padding;
        _rightConstraint.constant = -1*bigMargin;
    }
    [_txtMessage sizeToFit];
    [self layoutIfNeeded];
}

- (CGSize)labelSizeThatFits:(CGSize)size withText:(NSString *)text {
    UILabel *lbl = [[UILabel alloc] init];
    lbl.numberOfLines = 0;
    lbl.font = [UIFont systemFontOfSize:14.0];
    lbl.text = text;
    [lbl.text sizeWithAttributes:@{}];
    return [lbl sizeThatFits:size];
}

@end
