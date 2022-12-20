//
//  tooles.m
//  huoche
//
//  Created by kan xu on 11-1-22.
//  Copyright 2011 paduu. All rights reserved.
//

#import "tooles.h"
#import "AppDelegate.h"

@implementation tooles

+(NSString*)getIAPIDByPriceStr:(NSString*)aPrice payKind:(EPayKind)aPayKind{

	return @"";
}

+(NSString*)getLabelFromIndex:(NSInteger)aIndex{
	switch (aIndex) {
		case 0:
			return @"";
		case 1:
			return @"清\n香";
		case 2:
			return @"平\n安";
		case 3:
			return @"高\n升";
		case 4:
			return @"祈\n福";
		case 5:
			return @"鸿\n运";
		case 6:
			return @"长\n寿";
		case 7:
			return @"就\n业";
		case 8:
			return @"姻\n缘";
		case 9:
			return @"求\n子";
		case 10:
			return @"去\n病";
		case 11:
			return @"学\n业";
		case 12:
			return @"圆\n满";
		default:
			return @"";
	}
}

+(BOOL)verifyInputs:(NSString*)aStr forInputType:(EInputType)aType{
	switch (aType) {
		case EInputUsername:{
			NSString *userNameRegex = @"^[A-Za-z0-9]{5,20}+$";
			NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
			return [userNamePredicate evaluateWithObject:aStr];
		}
			break;
		case EInputPassword:{
			NSString *passWordRegex = @"^[a-zA-Z0-9]{5,20}+$";
			NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
			return [passWordPredicate evaluateWithObject:aStr];
		}
			break;
		default:
			return NO;
	}
	return NO;
}

+(NSString*)getErrorString:(NSInteger)aCode{
	switch (aCode) {
		case 200:return @"用户名为空。";
		case 201:return @"密码为空。";
		case 202:return @"用户名已经被占用。";
		case 203:return @"电子邮箱地址已经被占用。";
		case 204:return @"没有提供电子邮箱地址。";
		case 205:return @"找不到电子邮箱地址对应的用户。";
		case 206:return @"无法修改用户信息。";
		case 207:return @"不允许第三方登录。";
		case 208:return @"第三方帐号已经绑定到一个用户。";
		case 210:return @"用户名和密码不匹配。";
		case 211:return @"找不到用户。";
		case 212:return @"请提供手机号码。";
		case 213:return @"手机号码对应的用户不存在。";
		case 214:return @"手机号码已经被注册。";
		case 215:return @"未验证的手机号码。";
		case 216:return @"未验证的邮箱地址。";
		case 217:return @"无效的用户名。";
		case 218:return @"无效的密码。";
		case 219:return @"登录失败次数超过限制，请稍候再试，或者通过忘记密码重设密码。";
		default: return @"操作失败。";
	}
}

+(NSString*)getPicNameByFoName:(NSString*)aFoName {
//	NSArray *items = @[@"item1", @"item2", @"item3", @"item1", @"item2", @"item3", @"item1", @"item2", @"item3", @"item1", @"item2", @"item3", @"item1", @"item2", @"item3", @"item1", @"item2", @"item3", @"item1", @"item2", @"item3", @"item1", @"item2", @"item3", ];
//	NSInteger item = [items indexOfObject:aFoName];
	if ([aFoName isEqualToString:@"药师佛"]) {
		return @"fo_fx_ysf.jpg";
	} else if ([aFoName isEqualToString:@"释迦牟尼佛"]) {
		return @"3-131214154509137.jpg";
	} else if ([aFoName isEqualToString:@"阿弥陀佛"]) {
		return @"19-13121416204VY.jpg";
	} else if ([aFoName isEqualToString:@"普贤菩萨"]) {
		return @"19-131214162P0111.jpg";
	} else if ([aFoName isEqualToString:@"文殊师利菩萨"]) {
		return @"19-131214162925U5.jpg";
	} else if ([aFoName isEqualToString:@"观世音菩萨"]) {
		return @"19-1312141630344c.jpg";
	} else if ([aFoName isEqualToString:@"地藏王菩萨"]) {
		return @"19-131214163130R9.jpg";
	} else if ([aFoName isEqualToString:@"弥勒尊佛"]) {
		return @"19-131214163315C9.jpg";
	} else if ([aFoName isEqualToString:@"准提菩萨"]) {
		return @"19-1312141634261L.jpg";
	} else if ([aFoName isEqualToString:@"大势至菩萨"]) {
		return @"19-131214163549392.jpg";
	} else if ([aFoName isEqualToString:@"南无离怖如来"]) {
		return @"19-1312141F213157.jpg";
	} else if ([aFoName isEqualToString:@"南无金色宝光妙行成就如来"]) {
		return @"19-1312141F402255.jpg";
	} else if ([aFoName isEqualToString:@"南无拘那含牟尼佛"]) {
		return @"19-1312141F535N2.jpg";
	} else if ([aFoName isEqualToString:@"南无甘露王如来"]) {
		return @"19-1312141F6162a.jpg";
	} else if ([aFoName isEqualToString:@"南无广博身如来"]) {
		return @"19-1312141FH0224.jpg";
	} else if ([aFoName isEqualToString:@"南无法海雷音如来"]) {
		return @"19-1312141FP92S.jpg";
	} else if ([aFoName isEqualToString:@"南无宝月智严光音自在如来"]) {
		return @"19-1312141FUN45.jpg";
	} else if ([aFoName isEqualToString:@"宝胜如来"]) {
		return @"19-1312141F9433a.jpg";
	} else if ([aFoName isEqualToString:@"拘留孙佛"]) {
		return @"19-1312141G034S9.jpg";
	} else if ([aFoName isEqualToString:@"韦驮菩萨"]) {
		return @"19-1312141G11H54.jpg";
	} else if ([aFoName isEqualToString:@"毗卢遮那佛"]) {
		return @"19-1312141G2041L.jpg";
	} else if ([aFoName isEqualToString:@"婆罗利胜头羯罗夜"]) {
		return @"19-1312141G243159.jpg";
	} else if ([aFoName isEqualToString:@"南无无忧最胜吉祥如来"]) {
		return @"19-1312141G344J9.jpg";
	} else if ([aFoName isEqualToString:@"南无尸弃佛"]) {
		return @"19-1312141G43DV.jpg";
	} else {
		return @"fo_fx_ysf.jpg";
	}
}


+(NSString*)getXiangPicNameByXiangID:(int)aXiangID {
    switch (aXiangID) {
        case 0: // xiang
            return @"fo_gp_xiang.gif";
        case 1: // hua
            return @"fo_gp_flower.gif";
        case 2: // guo
            return @"fo_gp_fruit.gif";
        case 3: // shui
            return @"fo_gp_water.gif";
        default:
            return @"fo_gp_xiang.gif";
    }
}

@end
