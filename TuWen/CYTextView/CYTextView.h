//
//  CYTextView.h
//  TuWen
//
//  Created by GuoBin on 16/6/3.
//  Copyright © 2016年 GuoBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYTextView : UITextView

/**
 *  插入表情
 *
 *  @param emojiTag   表情name
 *  @param emojiImage 表情image
 */
- (void)insertEmoji:(NSString *)emojiTag emojiImage:(UIImage *)emojiImage;


/**
 * @brief 占位符文本,与UITextField的placeholder功能一致
 */
@property (nonatomic, strong) NSString *placeholder;

/**
 * @brief 占位符文本颜色
 */
@property (nonatomic, strong) UIColor *placeholderTextColor;

@end
