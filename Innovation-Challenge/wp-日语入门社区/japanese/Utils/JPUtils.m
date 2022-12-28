//
//  JPUtils.m
//  japanese
//
//  Created by LYQ on 2021/27.
//  Copyright (c) 2020 LYQ. All rights reserved.
//

#import "JPUtils.h"
#import "JPSoundBean.h"

@implementation JPUtils

static NSMutableArray *soundarray;
static NSMutableArray *allSound;
+ (NSMutableArray *)getQYSoundArray {

    if (soundarray){
        soundarray = nil;
    }
    soundarray = [[NSMutableArray alloc] init];
    JPSoundBean *a = [[JPSoundBean alloc] initWith:@"あ" pianjia:@"ア" luoma:@"a"];
    JPSoundBean *i = [[JPSoundBean alloc] initWith:@"い" pianjia:@"イ" luoma:@"i"];
    JPSoundBean *u = [[JPSoundBean alloc] initWith:@"う" pianjia:@"ウ" luoma:@"u"];
    JPSoundBean *e = [[JPSoundBean alloc] initWith:@"え" pianjia:@"エ" luoma:@"e"];
    JPSoundBean *o = [[JPSoundBean alloc] initWith:@"お" pianjia:@"オ" luoma:@"o"];

    JPSoundBean *ka = [[JPSoundBean alloc] initWith:@"か" pianjia:@"カ" luoma:@"ka"];
    JPSoundBean *ki = [[JPSoundBean alloc] initWith:@"き" pianjia:@"キ" luoma:@"ki"];
    JPSoundBean *ku = [[JPSoundBean alloc] initWith:@"く" pianjia:@"ク" luoma:@"ku"];
    JPSoundBean *ke = [[JPSoundBean alloc] initWith:@"け" pianjia:@"ケ" luoma:@"ke"];
    JPSoundBean *ko = [[JPSoundBean alloc] initWith:@"こ" pianjia:@"コ" luoma:@"ko"];

    JPSoundBean *sa = [[JPSoundBean alloc] initWith:@"さ" pianjia:@"サ" luoma:@"sa"];
    JPSoundBean *shi = [[JPSoundBean alloc] initWith:@"し" pianjia:@"シ" luoma:@"shi"];
    JPSoundBean *su = [[JPSoundBean alloc] initWith:@"す" pianjia:@"ス" luoma:@"su"];
    JPSoundBean *se = [[JPSoundBean alloc] initWith:@"せ" pianjia:@"セ" luoma:@"se"];
    JPSoundBean *so = [[JPSoundBean alloc] initWith:@"そ" pianjia:@"ソ" luoma:@"so"];

    JPSoundBean *ta = [[JPSoundBean alloc] initWith:@"た" pianjia:@"タ" luoma:@"ta"];
    JPSoundBean *chi = [[JPSoundBean alloc] initWith:@"ち" pianjia:@"チ" luoma:@"chi"];
    JPSoundBean *tsu = [[JPSoundBean alloc] initWith:@"つ" pianjia:@"ツ" luoma:@"tsu"];
    JPSoundBean *te = [[JPSoundBean alloc] initWith:@"て" pianjia:@"テ" luoma:@"te"];
    JPSoundBean *to = [[JPSoundBean alloc] initWith:@"と" pianjia:@"ト" luoma:@"to"];

    JPSoundBean *na = [[JPSoundBean alloc] initWith:@"な" pianjia:@"ナ" luoma:@"na"];
    JPSoundBean *ni = [[JPSoundBean alloc] initWith:@"に" pianjia:@"ニ" luoma:@"ni"];
    JPSoundBean *nu = [[JPSoundBean alloc] initWith:@"ぬ" pianjia:@"ヌ" luoma:@"nu"];
    JPSoundBean *ne = [[JPSoundBean alloc] initWith:@"ね" pianjia:@"ネ" luoma:@"ne"];
    JPSoundBean *no = [[JPSoundBean alloc] initWith:@"の" pianjia:@"ノ" luoma:@"no"];

    JPSoundBean *ha = [[JPSoundBean alloc] initWith:@"は" pianjia:@"ハ" luoma:@"ha"];
    JPSoundBean *hi = [[JPSoundBean alloc] initWith:@"ひ" pianjia:@"ヒ" luoma:@"hi"];
    JPSoundBean *fu = [[JPSoundBean alloc] initWith:@"ふ" pianjia:@"フ" luoma:@"fu"];
    JPSoundBean *he = [[JPSoundBean alloc] initWith:@"へ" pianjia:@"ヘ" luoma:@"he"];
    JPSoundBean *ho = [[JPSoundBean alloc] initWith:@"ほ" pianjia:@"ホ" luoma:@"ho"];

    JPSoundBean *ma = [[JPSoundBean alloc] initWith:@"ま" pianjia:@"マ" luoma:@"ma"];
    JPSoundBean *mi = [[JPSoundBean alloc] initWith:@"み" pianjia:@"ミ" luoma:@"mi"];
    JPSoundBean *mu = [[JPSoundBean alloc] initWith:@"む" pianjia:@"ム" luoma:@"mu"];
    JPSoundBean *me = [[JPSoundBean alloc] initWith:@"め" pianjia:@"メ" luoma:@"me"];
    JPSoundBean *mo = [[JPSoundBean alloc] initWith:@"も" pianjia:@"モ" luoma:@"mo"];

    JPSoundBean *ya = [[JPSoundBean alloc] initWith:@"や" pianjia:@"ヤ" luoma:@"ya"];
    JPSoundBean *yu = [[JPSoundBean alloc] initWith:@"ゆ" pianjia:@"ユ" luoma:@"yu"];
    JPSoundBean *yo = [[JPSoundBean alloc] initWith:@"よ" pianjia:@"ヨ" luoma:@"yo"];

    JPSoundBean *ra = [[JPSoundBean alloc] initWith:@"ら" pianjia:@"ラ" luoma:@"ra"];
    JPSoundBean *ri = [[JPSoundBean alloc] initWith:@"り" pianjia:@"リ" luoma:@"ri"];
    JPSoundBean *ru = [[JPSoundBean alloc] initWith:@"る" pianjia:@"ル" luoma:@"ru"];
    JPSoundBean *re = [[JPSoundBean alloc] initWith:@"れ" pianjia:@"レ" luoma:@"re"];
    JPSoundBean *ro = [[JPSoundBean alloc] initWith:@"ろ" pianjia:@"ロ" luoma:@"ro"];

    JPSoundBean *wa = [[JPSoundBean alloc] initWith:@"わ" pianjia:@"ワ" luoma:@"wa"];
    JPSoundBean *wo = [[JPSoundBean alloc] initWith:@"を" pianjia:@"ヲ" luoma:@"wo"];

    JPSoundBean *n = [[JPSoundBean alloc] initWith:@"ん" pianjia:@"ン" luoma:@"n"];

    [soundarray addObject:a];
    [soundarray addObject:i];
    [soundarray addObject:u];
    [soundarray addObject:e];
    [soundarray addObject:o];

    [soundarray addObject:ka];
    [soundarray addObject:ki];
    [soundarray addObject:ku];
    [soundarray addObject:ke];
    [soundarray addObject:ko];

    [soundarray addObject:sa];
    [soundarray addObject:shi];
    [soundarray addObject:su];
    [soundarray addObject:se];
    [soundarray addObject:so];

    [soundarray addObject:ta];
    [soundarray addObject:chi];
    [soundarray addObject:tsu];
    [soundarray addObject:te];
    [soundarray addObject:to];

    [soundarray addObject:na];
    [soundarray addObject:ni];
    [soundarray addObject:nu];
    [soundarray addObject:ne];
    [soundarray addObject:no];

    [soundarray addObject:ha];
    [soundarray addObject:hi];
    [soundarray addObject:fu];
    [soundarray addObject:he];
    [soundarray addObject:ho];

    [soundarray addObject:ma];
    [soundarray addObject:mi];
    [soundarray addObject:mu];
    [soundarray addObject:me];
    [soundarray addObject:mo];

    [soundarray addObject:ya];
    [soundarray addObject:i];
    [soundarray addObject:yu];
    [soundarray addObject:e];
    [soundarray addObject:yo];

    [soundarray addObject:ra];
    [soundarray addObject:ri];
    [soundarray addObject:ru];
    [soundarray addObject:re];
    [soundarray addObject:ro];

    [soundarray addObject:wa];
    [soundarray addObject:i];
    [soundarray addObject:u];
    [soundarray addObject:e];
    [soundarray addObject:wo];

    [soundarray addObject:n];
    return soundarray;
}

+ (NSMutableArray *)getQAYSoundArray {
    if (soundarray){
        soundarray = nil;
    }
    soundarray = [[NSMutableArray alloc] init];


    JPSoundBean *kya = [[JPSoundBean alloc] initWith:@"きゃ" pianjia:@"キャ" luoma:@"kya"];
    JPSoundBean *kyu = [[JPSoundBean alloc] initWith:@"きゅ" pianjia:@"キュ" luoma:@"kyu"];
    JPSoundBean *kyo = [[JPSoundBean alloc] initWith:@"きょ" pianjia:@"キョ" luoma:@"kyo"];

    JPSoundBean *sha = [[JPSoundBean alloc] initWith:@"しゃ" pianjia:@"シャ" luoma:@"sha"];
    JPSoundBean *shu = [[JPSoundBean alloc] initWith:@"しゅ" pianjia:@"シュ" luoma:@"shu"];
    JPSoundBean *sho = [[JPSoundBean alloc] initWith:@"しょ" pianjia:@"ショ" luoma:@"sho"];

    JPSoundBean *cha = [[JPSoundBean alloc] initWith:@"ちゃ" pianjia:@"チャ" luoma:@"cha"];
    JPSoundBean *chu = [[JPSoundBean alloc] initWith:@"ちゅ" pianjia:@"チュ" luoma:@"chu"];
    JPSoundBean *cho = [[JPSoundBean alloc] initWith:@"ちょ" pianjia:@"チョ" luoma:@"cho"];

    JPSoundBean *nya = [[JPSoundBean alloc] initWith:@"にゃ" pianjia:@"ニャ" luoma:@"nya"];
    JPSoundBean *nyu = [[JPSoundBean alloc] initWith:@"にゅ" pianjia:@"ニュ" luoma:@"nyu"];
    JPSoundBean *nyo = [[JPSoundBean alloc] initWith:@"にょ" pianjia:@"ニョ" luoma:@"nyo"];

    JPSoundBean *hya = [[JPSoundBean alloc] initWith:@"ひゃ" pianjia:@"ヒャ" luoma:@"hya"];
    JPSoundBean *hyu = [[JPSoundBean alloc] initWith:@"ひゅ" pianjia:@"ヒュ" luoma:@"hyu"];
    JPSoundBean *hyo = [[JPSoundBean alloc] initWith:@"ひょ" pianjia:@"ヒョ" luoma:@"hyo"];

    JPSoundBean *mya = [[JPSoundBean alloc] initWith:@"みゃ" pianjia:@"ミャ" luoma:@"mya"];
    JPSoundBean *myu = [[JPSoundBean alloc] initWith:@"みゅ" pianjia:@"ミュ" luoma:@"myu"];
    JPSoundBean *myo = [[JPSoundBean alloc] initWith:@"みょ" pianjia:@"ミョ" luoma:@"myo"];

    JPSoundBean *rya = [[JPSoundBean alloc] initWith:@"りゃ" pianjia:@"リャ" luoma:@"rya"];
    JPSoundBean *ryu = [[JPSoundBean alloc] initWith:@"りゅ" pianjia:@"リュ" luoma:@"ryu"];
    JPSoundBean *ryo = [[JPSoundBean alloc] initWith:@"りょ" pianjia:@"リョ" luoma:@"ryo"];

    [soundarray addObject:kya];
    [soundarray addObject:kyu];
    [soundarray addObject:kyo];

    [soundarray addObject:sha];
    [soundarray addObject:shu];
    [soundarray addObject:sho];

    [soundarray addObject:cha];
    [soundarray addObject:chu];
    [soundarray addObject:cho];

    [soundarray addObject:nya];
    [soundarray addObject:nyu];
    [soundarray addObject:nyo];

    [soundarray addObject:hya];
    [soundarray addObject:hyu];
    [soundarray addObject:hyo];

    [soundarray addObject:mya];
    [soundarray addObject:myu];
    [soundarray addObject:myo];

    [soundarray addObject:rya];
    [soundarray addObject:ryu];
    [soundarray addObject:ryo];

    return soundarray;
}

+ (NSMutableArray *)getZYSoundArray {

    JPSoundBean *ga = [[JPSoundBean alloc] initWith:@"が" pianjia:@"ガ" luoma:@"ga"];
    JPSoundBean *gi = [[JPSoundBean alloc] initWith:@"ぎ" pianjia:@"ギ" luoma:@"gi"];
    JPSoundBean *gu = [[JPSoundBean alloc] initWith:@"ぐ" pianjia:@"グ" luoma:@"gu"];
    JPSoundBean *ge = [[JPSoundBean alloc] initWith:@"げ" pianjia:@"ゲ" luoma:@"ge"];
    JPSoundBean *go = [[JPSoundBean alloc] initWith:@"ご" pianjia:@"ゴ" luoma:@"go"];


    JPSoundBean *za = [[JPSoundBean alloc] initWith:@"ざ" pianjia:@"ザ" luoma:@"za"];
    JPSoundBean *zi = [[JPSoundBean alloc] initWith:@"じ" pianjia:@"ジ" luoma:@"ji" shuru:@"zi"];
    JPSoundBean *zu = [[JPSoundBean alloc] initWith:@"ず" pianjia:@"ズ" luoma:@"zu"];
    JPSoundBean *ze = [[JPSoundBean alloc] initWith:@"ぜ" pianjia:@"ゼ" luoma:@"ze"];
    JPSoundBean *zo = [[JPSoundBean alloc] initWith:@"ぞ" pianjia:@"ゾ" luoma:@"zo"];

    JPSoundBean *da = [[JPSoundBean alloc] initWith:@"だ" pianjia:@"ダ" luoma:@"da"];
    JPSoundBean *di = [[JPSoundBean alloc] initWith:@"ぢ" pianjia:@"ヂ" luoma:@"ji" shuru:@"di"];
    JPSoundBean *du = [[JPSoundBean alloc] initWith:@"づ" pianjia:@"ヅ" luoma:@"zu" shuru:@"du"];
    JPSoundBean *de = [[JPSoundBean alloc] initWith:@"で" pianjia:@"デ" luoma:@"de"];
    JPSoundBean *dou = [[JPSoundBean alloc] initWith:@"ど" pianjia:@"ド" luoma:@"do"];

    JPSoundBean *ba = [[JPSoundBean alloc] initWith:@"ば" pianjia:@"バ" luoma:@"ba"];
    JPSoundBean *bi = [[JPSoundBean alloc] initWith:@"び" pianjia:@"ビ" luoma:@"bi"];
    JPSoundBean *bu = [[JPSoundBean alloc] initWith:@"ぶ" pianjia:@"ブ" luoma:@"bu"];
    JPSoundBean *be = [[JPSoundBean alloc] initWith:@"べ" pianjia:@"ベ" luoma:@"be"];
    JPSoundBean *bo = [[JPSoundBean alloc] initWith:@"ぼ" pianjia:@"ボ" luoma:@"bo"];

    JPSoundBean *pa = [[JPSoundBean alloc] initWith:@"ぱ" pianjia:@"パ" luoma:@"pa"];
    JPSoundBean *pi = [[JPSoundBean alloc] initWith:@"ぴ" pianjia:@"ピ" luoma:@"pi"];
    JPSoundBean *pu = [[JPSoundBean alloc] initWith:@"ぷ" pianjia:@"プ" luoma:@"pu"];
    JPSoundBean *pe = [[JPSoundBean alloc] initWith:@"ぺ" pianjia:@"ペ" luoma:@"pe"];
    JPSoundBean *po = [[JPSoundBean alloc] initWith:@"ぽ" pianjia:@"ポ" luoma:@"po"];

    if (soundarray){
        soundarray = nil;
    }
    soundarray = [[NSMutableArray alloc] init];

    [soundarray addObject:ga];
    [soundarray addObject:gi];
    [soundarray addObject:gu];
    [soundarray addObject:ge];
    [soundarray addObject:go];

    [soundarray addObject:za];
    [soundarray addObject:zi];
    [soundarray addObject:zu];
    [soundarray addObject:ze];
    [soundarray addObject:zo];

    [soundarray addObject:da];
    [soundarray addObject:di];
    [soundarray addObject:du];
    [soundarray addObject:de];
    [soundarray addObject:dou];

    [soundarray addObject:ba];
    [soundarray addObject:bi];
    [soundarray addObject:bu];
    [soundarray addObject:be];
    [soundarray addObject:bo];

    [soundarray addObject:pa];
    [soundarray addObject:pi];
    [soundarray addObject:pu];
    [soundarray addObject:pe];
    [soundarray addObject:po];

    return soundarray;
}

+ (NSMutableArray *)getZAYSoundArray {
    if (soundarray){
        soundarray = nil;
    }
    soundarray = [[NSMutableArray alloc] init];

    JPSoundBean *gya = [[JPSoundBean alloc] initWith:@"ぎゃ" pianjia:@"ギャ" luoma:@"gya"];
    JPSoundBean *gyu = [[JPSoundBean alloc] initWith:@"ぎゅ" pianjia:@"ギュ" luoma:@"gyu"];
    JPSoundBean *gyo = [[JPSoundBean alloc] initWith:@"ぎょ" pianjia:@"ギョ" luoma:@"gyo"];

    JPSoundBean *ja = [[JPSoundBean alloc] initWith:@"じゃ" pianjia:@"ジャ" luoma:@"ja"];
    JPSoundBean *ju = [[JPSoundBean alloc] initWith:@"じゅ" pianjia:@"ジュ" luoma:@"ju"];
    JPSoundBean *jo = [[JPSoundBean alloc] initWith:@"じょ" pianjia:@"ジョ" luoma:@"jo"];

    JPSoundBean *bya = [[JPSoundBean alloc] initWith:@"びゃ" pianjia:@"ビャ" luoma:@"bya"];
    JPSoundBean *byu = [[JPSoundBean alloc] initWith:@"びゅ" pianjia:@"ビュ" luoma:@"byu"];
    JPSoundBean *byo = [[JPSoundBean alloc] initWith:@"びょ" pianjia:@"ビョ" luoma:@"byo"];

    JPSoundBean *pya = [[JPSoundBean alloc] initWith:@"ぴゃ" pianjia:@"ピャ" luoma:@"pya"];
    JPSoundBean *pyu = [[JPSoundBean alloc] initWith:@"ぴゅ" pianjia:@"ピュ" luoma:@"pyu"];
    JPSoundBean *pyo = [[JPSoundBean alloc] initWith:@"ぴょ" pianjia:@"ピョ" luoma:@"pyo"];

    [soundarray addObject:gya];
    [soundarray addObject:gyu];
    [soundarray addObject:gyo];

    [soundarray addObject:ja];
    [soundarray addObject:ju];
    [soundarray addObject:jo];

    [soundarray addObject:bya];
    [soundarray addObject:byu];
    [soundarray addObject:byo];

    [soundarray addObject:pya];
    [soundarray addObject:pyu];
    [soundarray addObject:pyo];

    return  soundarray;
}

/**
 * 获取不同假名
 * @param type  0全部音    1五十音
 * @param count 0全部音 大于0 check用
 * @return
 */
+ (NSMutableArray *)getTypeArray:(NSInteger)type arraycount:(NSInteger)count{
    if (allSound){
        allSound = nil;
    }
    allSound = [[NSMutableArray alloc] init];
    [allSound addObjectsFromArray:[self getQYSoundArray]];
    if (type == 0){
        [allSound addObjectsFromArray:[self getQAYSoundArray]];
        [allSound addObjectsFromArray:[self getZYSoundArray]];
        [allSound addObjectsFromArray:[self getZAYSoundArray]];
    }
    if (type == 0 && count == 0){//返回所有列表
        return allSound;
    } else {//返回随机列表，check用
        NSInteger allcount = allSound.count;
        for (int i = 0; i < (allcount - count/2); ++i) {//返回需求数量的一半，因为需要分离假名
            NSInteger t = arc4random()%allSound.count;
            [allSound removeObjectAtIndex:t];
        }

        for (int j = 0; j < count/2; ++j) {
            JPSoundBean *nowbean = [allSound objectAtIndex:j];
            JPSoundBean *temp = [[JPSoundBean alloc] initWith:nowbean.pingjia pianjia:nowbean.pianjia luoma:nowbean.luoma shuru:nowbean.shuru];
            nowbean.checksound = nowbean.pingjia;
            nowbean.checktype = @"pingjia";
            temp.checksound = temp.pianjia;
            temp.checktype = @"pianjia";
            [allSound addObject:temp];
        }

        for (int k = 0; k < count; ++k) {
            NSInteger t = arc4random()%allSound.count;
            [allSound exchangeObjectAtIndex:k withObjectAtIndex:t];
        }
        return allSound;
    }

}


+ (UIColor *)getUIColorByString:(NSString *)hexcolor {
    NSMutableString *color = [[NSMutableString alloc] initWithString:hexcolor];
// 转换成标准16进制数
    [color replaceCharactersInRange:[color rangeOfString:@"#" ] withString:@"0x"];
// 十六进制字符串转成整形。
    long colorLong = strtoul([color cStringUsingEncoding:NSUTF8StringEncoding], 0, 16);
// 通过位与方法获取三色值
    int R = (colorLong & 0xFF0000 )>>16;
    int G = (colorLong & 0x00FF00 )>>8;
    int B =  colorLong & 0x0000FF;

//string转color
    return [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0];
}


@end
