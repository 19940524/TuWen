//
//  CYTextView.m
//  TuWen
//
//  Created by GuoBin on 16/6/3.
//  Copyright © 2016年 GuoBin. All rights reserved.
//

#import "CYTextView.h"
#import "EmojiTextAttachment.h"
#import "NSAttributedString+EmojiExtension.h"

static const CGFloat EMOJI_MAX_SIZE = 20;

static const CGFloat FONT = 15;

@interface CYTextView () <UITextViewDelegate>

@end

@implementation CYTextView

//- (instancetype)initWithFrame:(CGRect)frame {
//    if (self = [super initWithFrame:frame]) {
//        
//    }
//    return self;
//}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self updateLayout];
}

- (CGSize)intrinsicContentSize {
    CGRect textRect = [self.layoutManager usedRectForTextContainer:self.textContainer];
    CGFloat height = textRect.size.height + self.textContainerInset.top + self.textContainerInset.bottom;
    return CGSizeMake(UIViewNoIntrinsicMetric, height);
}

- (void)textDidChange:(NSNotification *)notification {
    [self updateLayout];
}

- (void)updateLayout
{
    [self invalidateIntrinsicContentSize];
    [self scrollRangeToVisible:self.selectedRange];
}

- (void)insertEmoji:(NSString *)emojiTag emojiImage:(UIImage *)emojiImage {
    
    EmojiTextAttachment *emojiTextAttachment = [EmojiTextAttachment new];
    
    emojiTextAttachment.emojiTag = emojiTag;
    emojiTextAttachment.image = emojiImage;
    
    emojiTextAttachment.emojiSize = CGSizeMake(EMOJI_MAX_SIZE, EMOJI_MAX_SIZE);
    
    [self.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:emojiTextAttachment]
                                     atIndex:self.selectedRange.location];
    
    self.selectedRange = NSMakeRange(self.selectedRange.location + 1, self.selectedRange.length);
    
    [self resetTextStyle];
    
    [self updateLayout];
}

- (void)resetTextStyle {
    
    NSRange wholeRange = NSMakeRange(0, self.textStorage.length);
    
    [self.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
    
    [self.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:FONT] range:wholeRange];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
