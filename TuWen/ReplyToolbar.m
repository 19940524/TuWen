//
//  ReplyToolbar.m
//  TuWen
//
//  Created by GuoBin on 16/6/4.
//  Copyright © 2016年 GuoBin. All rights reserved.
//

#import "ReplyToolbar.h"
#import "NSAttributedString+EmojiExtension.h"

//屏幕的物理尺寸
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ReplyToolbar () {
    BOOL _isNeedPopEmoji;
}

@property (strong, nonatomic) UIButton *emojiButton;

@end

static CGFloat const MaxToolbarHeight = 100.0f;

@implementation ReplyToolbar
@synthesize keyboardHeight = _keyboardHeight;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replyKeyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replyKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        _keyboardHeight = -1;
        [self initSubView];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)initSubView {
    
    UIButton *sendMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendMessageButton.translatesAutoresizingMaskIntoConstraints = NO;
    [sendMessageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendMessageButton setTitle:@"发送" forState:UIControlStateNormal];
    sendMessageButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [sendMessageButton setBackgroundImage:[UIImage imageNamed:@"community_quandetail_send"] forState:UIControlStateNormal];
    [sendMessageButton addTarget:self action:@selector(sendMessageAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendMessageButton];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[sendMessageButton(65)]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sendMessageButton)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sendMessageButton(35)]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sendMessageButton)]];
    
    UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    emojiButton.translatesAutoresizingMaskIntoConstraints = NO;
    [emojiButton setImage:[UIImage imageNamed:@"community_quandetail_emoji"] forState:UIControlStateNormal];
    [emojiButton setImage:[UIImage imageNamed:@"community_quandetail_send"] forState:UIControlStateSelected];
    [emojiButton addTarget:self action:@selector(tapEmojiAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:emojiButton];
    self.emojiButton = emojiButton;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[emojiButton(40)]-3-[sendMessageButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(emojiButton,sendMessageButton)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[emojiButton(40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(emojiButton)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:emojiButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:sendMessageButton attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0]];
    
    CYTextView *textView = [[CYTextView alloc] init];
    textView.placeholder = @"  评论一个吧~";
    textView.placeholderTextColor = [UIColor lightGrayColor];
    textView.font = [UIFont systemFontOfSize:17.0f];
    textView.textContainerInset = UIEdgeInsetsMake(5.0f, 3.0f, 3.0f, 3.0f);
    textView.layer.borderWidth = 0.6f;
    textView.layer.cornerRadius = 5;
    textView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor;
    textView.layer.masksToBounds = YES;
    [self addSubview:textView];
    self.textView = textView;
    
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[textView]-3-[emojiButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textView,emojiButton)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[textView]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textView)]];
    
    [textView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [textView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:MaxToolbarHeight]];
}

#pragma mark - 弹出表情
- (void)tapEmojiAction:(UIButton *)button {
    if (button.selected) {
        button.selected = NO;
    } else {
        button.selected = YES;
    }
    if ([_replyDelegate respondsToSelector:@selector(popEmojiEvent:)]) {
        _isNeedPopEmoji = button.selected;
        
        if (button.selected) {
            
            if (!self.textView.resignFirstResponder) {
                self.textView.inputView = [UIView new];
                [self.textView becomeFirstResponder];
                [self reLayoutToolbar:0.2f interval:self.keyboardHeight];
                
            } else {
                
                [self.textView resignFirstResponder];
                self.textView.inputView = [UIView new];
                [self.textView becomeFirstResponder];
                [self reLayoutToolbar:0.2f interval:self.keyboardHeight];
            }
            
        } else {
            self.textView.inputView = nil;
            [self.textView resignFirstResponder];
            [self.textView becomeFirstResponder];
        }
        [_replyDelegate popEmojiEvent:button.selected];
        
    }
}

#pragma mark - 发送消息
- (void)sendMessageAction {
    
    if ([_replyDelegate respondsToSelector:@selector(sendMessageEvent:)]) {
        [_replyDelegate sendMessageEvent:[self.textView.textStorage getPlainString]];
        
        if (self.textView.resignFirstResponder) {
            [_replyDelegate popEmojiEvent:NO];
            _isNeedPopEmoji = NO;
            [self reSubViewData];
            [self reLayoutToolbar:0.2f interval:-self.frame.size.height];
        }
    }
}

#pragma mark 重置视图配置
- (void)reSubViewData {
    self.emojiButton.selected = NO;
    self.textView.text = nil;
    self.textView.inputView = nil;
}

#pragma mark 键盘已经出现
- (void)replyKeyboardDidShow:(NSNotification *)notification {
    CGRect frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    if (!_isNeedPopEmoji) {
        [self reLayoutToolbar:duration interval:frame.size.height];
    }
}

#pragma mark 键盘即将隐藏
- (void)replyKeyboardWillHide:(NSNotification *)notification {
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    if (!_isNeedPopEmoji) {
        [self reLayoutToolbar:duration interval:-self.frame.size.height];
    }
}

#pragma mark 重新布局toolbary坐标
- (void)reLayoutToolbar:(double)duration interval:(double)interval {
    NSArray *constraints = [[self superview] constraints];
    for (NSLayoutConstraint *layoutCon in constraints) {
        if ([layoutCon.firstItem isEqual:[self superview]] && [layoutCon.secondItem isEqual:self] && layoutCon.secondAttribute == NSLayoutAttributeBottom) {
            layoutCon.constant = interval;
        }
    }
    
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)setKeyboardHeight:(CGFloat)height {
    if ([_replyDataSource respondsToSelector:@selector(getKeyboardHeight)]) {
        _keyboardHeight = [_replyDataSource getKeyboardHeight];
        return;
    }
    _keyboardHeight = height;
}

- (CGFloat)keyboardHeight {
    if (_keyboardHeight < 0) {
        if ([_replyDataSource respondsToSelector:@selector(getKeyboardHeight)]) {
            _keyboardHeight = [_replyDataSource getKeyboardHeight];
        }
    }
    return _keyboardHeight;
}

@end
