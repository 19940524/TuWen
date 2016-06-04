//
//  ViewController.m
//  TuWen
//
//  Created by GuoBin on 16/6/3.
//  Copyright © 2016年 GuoBin. All rights reserved.
//

#import "ViewController.h"
#import "CYTextView.h"
#import "ReplyToolbar.h"
#import <MLLabel/MLLinkLabel.h>
#import <MLLabel/NSString+MLExpression.h>

//屏幕的物理尺寸
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define SHOW_SIMPLE_TIPS(m) [[[UIAlertView alloc] initWithTitle:@"" message:(m) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];

static const CGFloat keyboardHeight = 250;

@interface ViewController () <ReplyToobarDelegate> {
    CGRect keyboardFrame;
    BOOL _isNeedPopEmoji;
}

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet MLLinkLabel *textLabel;
@property (strong, nonatomic) ReplyToolbar *toolbar;;

@property (strong, nonatomic) UIView *emojiView;

@property (strong, nonatomic) NSArray *emojiTags;
@property (strong, nonatomic) NSArray *emojiImages;

@property (strong, nonatomic) MLExpression *exp;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    _emojiTags = @[@"[emoji_1]", @"[emoji2]", @"[emoji3]", @"[emoji4]"];
    _emojiImages = @[[UIImage imageNamed:@"emoji_1_big"], [UIImage imageNamed:@"emoji_2_big"],
                     [UIImage imageNamed:@"emoji_3_big"], [UIImage imageNamed:@"emoji_4_big"]];
    
    [self.view addSubview:self.toolbar];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_toolbar)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_toolbar(>=40)]-(-40)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_toolbar)]];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillShow:)
                                                name:UIKeyboardDidShowNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(keyboardWillHide:)
                                                name:UIKeyboardWillHideNotification
                                              object:nil];
    
    self.textLabel.textColor = [UIColor redColor];
    self.textLabel.font = [UIFont systemFontOfSize:16.0f];
    self.textLabel.numberOfLines = 0;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.textInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    self.textLabel.allowLineBreakInsideLinks = NO;
    self.textLabel.linkTextAttributes = nil;
    self.textLabel.activeLinkTextAttributes = nil;
    
    MLExpression *exp = [MLExpression expressionWithRegex:@"\\[[a-zA-Z0-9_\\u4e00-\\u9fa5]+\\]" plistName:@"Expression" bundleName:@"ClippedExpression"];
    self.exp = exp;
    //注意，[心碎了]这个其实是匹配了正则，但是没有对应图像的，这里是故意加个这样的来测试。
    //    self.textLabel.attributedText = [@"人生若只如初见，[坏笑]何事秋风悲画扇。http://baidu.com等闲变却故人心[亲亲]，dudl@qq.com却道故人心易变。13612341234骊山语罢清宵半[心碎了]，泪雨零铃终不怨[左哼哼]。#何如 薄幸@锦衣郎，比翼连枝当日愿。" expressionAttributedStringWithExpression:exp];
    
    [self.textLabel setDidClickLinkBlock:^(MLLink *link, NSString *linkText, MLLinkLabel *label) {
        NSString *tips = [NSString stringWithFormat:@"Click\nlinkType:%ld\nlinkText:%@\nlinkValue:%@",link.linkType,linkText,link.linkValue];
        SHOW_SIMPLE_TIPS(tips);
    }];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    CGRect frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = frame;
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    
    if (!_isNeedPopEmoji) {
        [self reLayoutToolbar:duration interval:-40];
    }
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGRect frame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    keyboardFrame = frame;
    
    if (!_isNeedPopEmoji) {
        
        [self reLayoutToolbar:duration interval:frame.size.height];
    }
}

- (void)reLayoutToolbar:(double)duration interval:(double)interval {
    NSArray *constraints = [self.view constraints];
    for (NSLayoutConstraint *layoutCon in constraints) {
        if ([layoutCon.firstItem isEqual:self.view] && [layoutCon.secondItem isEqual:_toolbar] && layoutCon.secondAttribute == NSLayoutAttributeBottom) {
            layoutCon.constant = interval;
        }
    }
    
    [UIView animateWithDuration:duration animations:^{
        [_toolbar layoutIfNeeded];
    }];
}

- (UIView *)emojiView {
    if (!_emojiView) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"EmojiView" owner:nil options:nil];
        _emojiView = [nibs objectAtIndex:0];
        for (UIView *view in _emojiView.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                [button addTarget:self action:@selector(insertEmoji:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        [self.view addSubview:_emojiView];
    }
    return _emojiView;
}

- (ReplyToolbar *)toolbar {
    if (!_toolbar) {
        _toolbar = [[ReplyToolbar alloc] init];
        _toolbar.replyDelegate = self;
        [self.view addSubview:_emojiView];
    }
    return _toolbar;
}

#pragma mark - ReplyToobarDelegate
- (void)sendMessageEvent:(NSString *)message {
    self.textLabel.text = message;
    self.textLabel.attributedText = [message expressionAttributedStringWithExpression:self.exp];
    
    if (_toolbar.textView.resignFirstResponder) {

        [self popEmojiView:NO];
        _isNeedPopEmoji = NO;
        [_toolbar reSubViewData];
        [self reLayoutToolbar:0.2f interval:-40];
    }
}

- (void)popEmojiEvent:(BOOL)isPop {
    _isNeedPopEmoji = isPop;
    
    if (isPop) {
        [self popEmojiView:YES];
        
        if (!_toolbar.textView.resignFirstResponder) {
            _toolbar.textView.inputView = [UIView new];
            [_toolbar.textView becomeFirstResponder];
            [self reLayoutToolbar:0.2f interval:keyboardHeight];
            
        } else {
            
            [_toolbar.textView resignFirstResponder];
            _toolbar.textView.inputView = [UIView new];
            [_toolbar.textView becomeFirstResponder];
            [self reLayoutToolbar:0.2f interval:keyboardHeight];
        }
        
    } else {
        
        [self popEmojiView:NO];
        _toolbar.textView.inputView = nil;
        [_toolbar.textView resignFirstResponder];
        [_toolbar.textView becomeFirstResponder];
    }
}

- (void)popEmojiView:(BOOL)ispop {
    [self.view bringSubviewToFront:self.emojiView];
    CGRect frame = CGRectMake(0, ispop ? kScreenHeight - keyboardHeight : kScreenHeight, kScreenWidth, keyboardHeight);
    
    self.emojiView.frame = CGRectMake(0, ispop ? kScreenHeight : kScreenHeight - keyboardHeight, kScreenWidth, keyboardHeight);
    [UIView animateWithDuration:0.2f animations:^{
        self.emojiView.frame = frame;
    }];
}

- (IBAction)replyAction:(UIButton *)sender {
    [_toolbar.textView becomeFirstResponder];
}

- (void)insertEmoji:(UIButton *)button {
    
    NSString *tmojiString = [_emojiTags objectAtIndex:button.tag];
    UIImage *image = [_emojiImages objectAtIndex:button.tag];
    
    [_toolbar.textView insertEmoji:tmojiString emojiImage:image];
    
}

// 成为第一响应者  重写inputAccessoryView
//- (BOOL)canBecomeFirstResponder {
//    return YES;
//}

//- (UIView *)inputAccessoryView {
//    if (_toolbar) {
//        return _toolbar;
//    }

//    _toolbar = [UIToolbar new];
//    
//    CYTextView *textView = [[CYTextView alloc] init];
//    textView.font = [UIFont systemFontOfSize:17.0f];
//    textView.textContainerInset = UIEdgeInsetsMake(4.0f, 3.0f, 3.0f, 3.0f);
//    textView.layer.cornerRadius = 4.0f;
//    textView.layer.borderColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:205.0f/255.0f alpha:1.0f].CGColor;
//    textView.layer.borderWidth = 1.0f;
//    textView.layer.masksToBounds = YES;
//    [_toolbar addSubview:textView];
//    
//    textView.translatesAutoresizingMaskIntoConstraints = NO;
//    _toolbar.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    [_toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[textView]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textView)]];
//    [_toolbar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[textView]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textView)]];
//    
//    [textView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//    [textView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
//    [_toolbar setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
//    
//    [_toolbar addConstraint:[NSLayoutConstraint constraintWithItem:_toolbar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:MaxToolbarHeight]];

//    return self.toolbar;
//}

//- (IBAction)insertEmoji:(UIButton *)sender {
//    _emojiTags[(NSUInteger) sender.tag];
//    emojiTextAttachment.image = _emojiImages[(NSUInteger) sender.tag];

//    NSString *tmojiString = [_emojiTags objectAtIndex:sender.tag];
//    UIImage *image = [_emojiImages objectAtIndex:sender.tag];

//    [self.cyTextView insertEmoji:tmojiString emojiImage:image];
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
