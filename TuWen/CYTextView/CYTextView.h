//
//  CYTextView.h
//  TuWen
//
//  Created by GuoBin on 16/6/3.
//  Copyright © 2016年 GuoBin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYTextView : UITextView

- (void)insertEmoji:(NSString *)emojiTag emojiImage:(UIImage *)emojiImage;

- (void)resetTextStyle;

@end
