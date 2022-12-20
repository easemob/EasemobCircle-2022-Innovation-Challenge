//
//  tooles.h
//  huoche
//
//  Created by kan xu on 11-1-22.
//  Copyright 2011 paduu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    EPayHY = 1,
    EPayXH = 2,
    EPayFN = 3,
}EPayKind;

typedef enum
{
    EInputUsername = 1,
    EInputPassword = 2,
}EInputType;

@interface tooles : NSObject

+(NSString*)getIAPIDByPriceStr:(NSString*)aPrice payKind:(EPayKind)aPayKind;
+(NSString*)getLabelFromIndex:(NSInteger)aIndex;

+(BOOL)verifyInputs:(NSString*)aStr forInputType:(EInputType)aType;
+(NSString*)getErrorString:(NSInteger)aCode;

+(NSString*)getPicNameByFoName:(NSString*)aFoName;
+(NSString*)getXiangPicNameByXiangID:(int)aXiangID;

@end
