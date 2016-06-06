//
//  Created by GuoBin on 16/6/3.
//  Copyright © 2016年 GuoBin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (CYEmojiExtension)

/**
 *  将文本中的表情转字符串
 *
 *  @return 字符串
 */
- (NSString *)getPlainString;
@end