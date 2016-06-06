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

@interface ViewController () <ReplyToolbarDelegate,ReplyToolbarDataSource> {
    NSArray *_attributeds;
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
    
    _attributeds = @[@{NSForegroundColorAttributeName : [UIColor colorWithRed:73 / 255.0f green:172 / 255.0f blue:213 / 255.0f alpha:1], NSFontAttributeName : [UIFont systemFontOfSize:14]},
      @{NSForegroundColorAttributeName : [UIColor colorWithRed:53 / 255.0f green:53 / 255.0f blue:53 / 255.0f alpha:1] , NSFontAttributeName : [UIFont systemFontOfSize:14]}];
    
    
    [self.view addSubview:self.toolbar];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolbar]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_toolbar)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_toolbar(>=44)]-(-44)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_toolbar)]];
    
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
        _toolbar.replyDataSource = self;
//        _toolbar.keyboardHeight = keyboardHeight;
        [self.view addSubview:_emojiView];
    }
    return _toolbar;
}

#pragma mark - ReplyToolbarDelegate
- (void)sendMessageEvent:(NSString *)message {
    self.textLabel.text = message;
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:[message expressionAttributedStringWithExpression:self.exp]];
    
        NSArray *strings = [attrString.string componentsSeparatedByString:@": "];
    
        if (strings.count > 0 && attrString.length > 0) {
            NSString *nickname = strings[0];
            NSRange range1 = NSMakeRange(0, nickname.length+1);
            NSDictionary *attrDic = [_attributeds objectAtIndex:0];  // @{NSForegroundColorAttributeName : ColorFromRGB(73, 172, 213), NSFontAttributeName : [UIFont systemFontOfSize:14]}
            [attrString addAttributes:attrDic range:range1];
            if (strings.count > 1) {
                NSString *content = strings[1];
                NSRange range2 = NSMakeRange(nickname.length+2, content.length);
                NSDictionary *attrDic2 = [_attributeds objectAtIndex:1]; // @{NSForegroundColorAttributeName : ColorFromRGB(53, 53, 53) , NSFontAttributeName : [UIFont systemFontOfSize:14]}
                [attrString addAttributes:attrDic2 range:range2];
    
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                [paragraphStyle setLineSpacing:2];//调整行间距
                [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrString.string.length)];
            }
        }
    
    self.textLabel.attributedText = attrString;
    
}

- (void)popEmojiEvent:(BOOL)isPop {
    [self popEmojiView:isPop];
}

#pragma mark ReplyToolbarDataSource
- (CGFloat)getKeyboardHeight {
    return 260;
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
