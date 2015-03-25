//
//  ARView.h
//  ARMetaioTest
//
//  Created by 池田昂平 on 2014/11/18.
//  Copyright (c) 2014年 池田昂平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MetaioSDKViewController.h"

@interface ARView : UIView{
    //静電マーカー
    CGPoint prev_center; //中心（以前）
    CGPoint center; //中心
    CGPoint fixP1_posi; //固定点の座標
    CGPoint fixP2_posi;
    CGPoint fixP3_posi;
    CGPoint cenP_posi; //中央点の座標
    
    //中央の可変点からの距離
    float dis1; //固定点1
    float dis2; //固定点2
    float dis3; //固定点3
    
    float dis_fp2fp3;
    float dis_fp2cenP;
    
    float degree; //回転角
    CGPoint sumDistance; //移動距離の総和
    NSString *moveState; //移動した方向
    BOOL moveFlag; //移動したかどうか
    
    NSMutableArray *prev_fixedpointsPosi; //固定点の座標（以前）
    NSMutableArray *curr_fixedpointsPosi; //固定点の座標（現在）*findSameFixedPointsで使用
}

//ARに関するプロパティ
@property BOOL armarkerRecog;
@property int aridNum;
@property metaio::Vector3d transComp; //3次元座標 (AR)
@property metaio::Vector2d arLocation; //2次元座標 (AR)
@property CGPoint arLocaCGPoint; //座標 (AR)
@property metaio::Vector3d rotation; //座標 (AR)

//capa(静電マーカー)に関するプロパティ
@property BOOL capaRecog;
@property int capaidNum;
@property NSArray *touchObjects; //タッチオブジェクト
@property BOOL calcReset;
//@property CGPoint centGrav; //重心 (静電マーカー)
//@property CGPoint precentGrav; //以前の重心 (静電マーカー)

//@property(nonatomic, readonly) CGFloat majorRadius;

@property AVAudioPlayer *capaRecogSound;

@end
