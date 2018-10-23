//
//  hDefine.h
//  HLWebViewAdvice
//
//  Created by zss on 2018/10/23.
//  Copyright © 2018年 HL. All rights reserved.
//

#ifndef hDefine_h
#define hDefine_h
#import "HLScreenFitTool.h"
//375宽做基本尺寸标准
#define kWidthMultiple6 (kFullScreenWidth/375)
#define kFullScreenSize [UIScreen mainScreen].bounds.size
#define kFullScreenWidth [UIScreen mainScreen].bounds.size.width
#define HLSizeW(value) [HLScreenFitTool percentageWidth:(value/1.0)]
#define HLFitSizeW(value) [HLScreenFitTool widthFitSize:(value/1.0)]
#define kDevice_Is_iPhoneX ([UIScreen mainScreen].bounds.size.width >= 375 && [UIScreen mainScreen].bounds.size.height >= 812)

#endif /* hDefine_h */
