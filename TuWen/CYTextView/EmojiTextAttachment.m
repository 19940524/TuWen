//
//  EmojiTextAttachment.m
//  TuWen
//
//  Created by GuoBin on 16/6/3.
//  Copyright © 2016年 GuoBin. All rights reserved.
//

#import "EmojiTextAttachment.h"

@implementation EmojiTextAttachment
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    return CGRectMake(0, 0, _emojiSize.width, _emojiSize.height);
}
@end
