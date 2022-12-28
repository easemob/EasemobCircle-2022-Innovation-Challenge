//
//  AppConstant.h
//  japanese
//
//  Created by LYQ on 2021/27.
//  Copyright (c) 2020 LYQ. All rights reserved.
//

#ifndef AppConstant_h
#define AppConstant_h

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define StatusBarHeight    20
#define TabBarHeight       49
#define NavBarHeight       44
#define StartY             64
#define NormalHeight       [UIScreen mainScreen].bounds.size.height-20-44
#define KEYBORD_HEIGHT     258
#define CellBackgroundColor ([JPUtils getUIColorByString:@"#97C2A7"])
#define JPCheckCellClickedColor ([JPUtils getUIColorByString:@"#57CADB"])
#define JPCheckCellNormalColor ([JPUtils getUIColorByString:@"#C9AEAE"])

#endif /* AppConstant_h */
