//
//  EmojiTextAttachment.h
//  TuWen
//
//  Created by GuoBin on 16/6/3.
//  Copyright © 2016年 GuoBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYEmojiTextAttachment : NSTextAttachment

/**
 *  表情nameß
 */
@property(strong, nonatomic) NSString *emojiTag;
/**
 *  表情大小
 */
@property(assign, nonatomic) CGSize emojiSize;
@end
