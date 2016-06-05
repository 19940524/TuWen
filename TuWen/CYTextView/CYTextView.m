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

@interface CYTextView () <UITextViewDelegate> {
    BOOL _shouldDrawPlaceholder;
}

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
        
        [self configureBase];
    }
    return self;
}

- (void)configureBase {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:self];
    
    self.placeholderTextColor = [UIColor colorWithWhite:0.702f alpha:1.0f];
    _shouldDrawPlaceholder = NO;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

#pragma mark - 重写父类方法
- (void)setText:(NSString *)text {
    [super setText:text];
    [self updateLayout];
    [self drawPlaceholder];
}

- (CGSize)intrinsicContentSize {
    CGRect textRect = [self.layoutManager usedRectForTextContainer:self.textContainer];
    CGFloat height = textRect.size.height + self.textContainerInset.top + self.textContainerInset.bottom;
    return CGSizeMake(UIViewNoIntrinsicMetric, height);
}

#pragma mark - 正在编辑
- (void)textDidChange:(NSNotification *)notification {
    [self updateLayout];
    [self drawPlaceholder];
}

#pragma mark - 更新约束
- (void)updateLayout {
    [self invalidateIntrinsicContentSize];
    [self scrollRangeToVisible:self.selectedRange];
}

#pragma mark - 插入表情
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
    [self drawPlaceholder];
}

- (void)resetTextStyle {
    
    NSRange wholeRange = NSMakeRange(0, self.textStorage.length);
    [self.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
    [self.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:FONT] range:wholeRange];
}

#pragma mark - 绘制占位符
- (void)drawPlaceholder {
    BOOL prev = _shouldDrawPlaceholder;
    _shouldDrawPlaceholder = self.placeholder && self.placeholderTextColor && self.text.length == 0;
    
    if (prev != _shouldDrawPlaceholder) {
        [self setNeedsDisplay];
    }
    return;
}

- (void)setPlaceholder:(NSString *)placeholder {
    if (![placeholder isEqual:_placeholder]) {
        _placeholder = placeholder;
        [self drawPlaceholder];
    }
    return;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (_shouldDrawPlaceholder) {
        [_placeholderTextColor set];
        [_placeholder drawInRect:CGRectMake(8.0f, 8.0f, self.frame.size.width - 16.0f,
                                            self.frame.size.height - 16.0f) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15],NSForegroundColorAttributeName : self.placeholderTextColor}];
    }
    return;
}

@end
