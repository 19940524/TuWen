//
//  ReplyToolbar.h
//  TuWen
//
//  Created by GuoBin on 16/6/4.
//  Copyright © 2016年 GuoBin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYTextView.h"

@protocol ReplyToobarDelegate <NSObject>

@required
/**
 *  发送消息
 *
 *  @param message 消息体
 *
 *  @return 是否收键盘
 */
- (void)sendMessageEvent:(NSString *)message;

/**
 *  弹出自定义表情
 *
 *  @param isPop YES 弹出表情  NO 返回输入法
 */
- (void)popEmojiEvent:(BOOL)isPop;

@end

@interface ReplyToolbar : UIToolbar

/**
 *  UITextView
 */
@property (strong, nonatomic) CYTextView *textView;

/**
 *  代理
 */
@property (strong, nonatomic) id <ReplyToobarDelegate> replyDelegate;

/**
 *  重置subview 配置
 */
- (void)reSubViewData;

@end
