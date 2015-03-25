//
//  ARView.m
//  ARMetaioTest
//
//  Created by 池田昂平 on 2014/11/18.
//  Copyright (c) 2014年 池田昂平. All rights reserved.
//

#import "ARView.h"

@implementation ARView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //値の初期化
        self.armarkerRecog = NO;
        self.aridNum = 0;
        self.multipleTouchEnabled = YES;
        prev_fixedpointsPosi = [[NSMutableArray alloc] init];
        curr_fixedpointsPosi = [[NSMutableArray alloc] init];
        sumDistance = CGPointMake(0, 0);
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"recog" ofType:@"wav"];
        NSURL *url = [NSURL fileURLWithPath:path];
        self.capaRecogSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
        
        UIColor *dblue = [UIColor colorWithRed:0x33/255.0 green:0 blue:0x99/255.0 alpha:0.0];
        //UIColor *color = [UIColor blackColor];
        //UIColor *acolor = [color colorWithAlphaComponent:0.5]; //透過率50%
        //self.backgroundColor = acolor;
        self.backgroundColor = dblue;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    UIColor *dblue = [UIColor colorWithRed:0x33/255.0 green:0 blue:0x99/255.0 alpha:0.0];
    UIColor *blue = [UIColor colorWithRed:0.098 green:0.098 blue:0.439 alpha:0.8];
    UIColor *deepskyblue = [UIColor colorWithRed:0 green:0.749 blue:1 alpha:1.0];
    
    if(self.armarkerRecog){
        //ARマーカー認識成功
        
        self.backgroundColor = dblue;
        
        NSString *arRecogTxt = @"Detected the Marker.";
        CGPoint point = CGPointMake(50, 50);
        UIFont *font = [UIFont systemFontOfSize:50];
        [arRecogTxt drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: deepskyblue}];
        
        
        NSString *arCoordinateTxt = [NSString stringWithFormat:@"Position: (%.0f, %.0f)",self.arLocaCGPoint.x, self.arLocaCGPoint.y];
        
        float arRotation = self.rotation.z;
        arRotation = arRotation + 180; // -180~180° → 0~360°．
        arRotation = arRotation + 90; //0~360° → 90~450°（90°足して0°が来る向きを合わせる．）
        arRotation = fmodf(arRotation, 360);
        NSString *arRotationTxt = [NSString stringWithFormat:@"Rotation: %.0f°", arRotation];
        
        CGPoint point_coordinate = CGPointMake(50, 150);
        CGPoint point_rotation = CGPointMake(50, 250);
        
        [arCoordinateTxt drawAtPoint:point_coordinate withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: deepskyblue}];
        [arRotationTxt drawAtPoint:point_rotation withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: deepskyblue}];

        
        //mm → pxに変換
        /*
        float arlocationX = (self.arLocation.x / 25.4) * 132;
        float arlocationY = (self.arLocation.y / 25.4) * 132;
        NSLog(@"arlocationX = %f", arlocationX);
        NSLog(@"arlocationY = %f", arlocationY);
        */
        
        //円描画
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 5.0);
        CGContextSetStrokeColorWithColor(context, [deepskyblue CGColor]);
        CGContextStrokeEllipseInRect(context, CGRectMake(self.arLocaCGPoint.x - 50, self.arLocaCGPoint.y - 100, 200 + self.transComp.z + 260, 200 + self.transComp.z + 260));
        //CGContextStrokeEllipseInRect(context, CGRectMake(arlocationX - 150, arlocationY - 150, 100, 100));
        
        //ID認識成功
        if(self.aridNum > 0){
            NSString *idTxt = [NSString stringWithFormat: @"ID: NO.%d.", self.aridNum];
            CGPoint point2 = CGPointMake(450, 250);
            UIFont *font2 = [UIFont systemFontOfSize:50];
            //[idTxt drawAtPoint:point2 withAttributes:@{NSFontAttributeName:font2, NSForegroundColorAttributeName: [UIColor orangeColor]}];
            [idTxt drawAtPoint:point2 withAttributes:@{NSFontAttributeName:font2, NSForegroundColorAttributeName: [UIColor orangeColor]}];
        }
    }
    
    /*
    for (UITouch *touch in self.touchObjects){
        CGPoint location = [touch locationInView:self];
        
        //接地面積の取得
        CGFloat majorRadi = [[touch valueForKey:@"pathMajorRadius"] floatValue];
        NSLog(@"接地面積: %f", majorRadi);
        
        //テキスト表示
        NSString *text = [NSString stringWithFormat: @"%0.1f, %0.1f, 接触面積：%0.1f", location.x, location.y, majorRadi];
        CGPoint point = CGPointMake(location.x, location.y);
        [text drawAtPoint:point withAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
    */
    
    
    //静電マーカー認識が成功した場合に描画
    if(self.capaRecog){
        
        self.backgroundColor = blue;
        
        //メッセージ表示
        NSString *message = @"Detected the Marker.";
        CGPoint point = CGPointMake(50, 50);
        UIFont *font = [UIFont systemFontOfSize:50];
        [message drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: deepskyblue}];
        
        /*
        //移動の向きを表示
        if(moveFlag == YES){
            UIFont *font_move = [UIFont boldSystemFontOfSize:80];
            [moveState drawAtPoint:CGPointMake(50, 250) withAttributes:@{NSFontAttributeName:font_move, NSForegroundColorAttributeName: deepskyblue}];
        }
        */
        
        /*
        //座標を表示
        NSString *locationStr = [NSString stringWithFormat:@"Location: (%.0f, %.0f)", center.x, center.y];
        UIFont *font_move_loca = [UIFont systemFontOfSize:50];
        [locationStr drawAtPoint:CGPointMake(50, 150) withAttributes:@{NSFontAttributeName:font_move_loca, NSForegroundColorAttributeName: deepskyblue}];
         */
        
        //回転角度を表示
        NSString *degreeStr = [NSString stringWithFormat:@"Rotation: %.0lf°", degree];
        UIFont *font_move = [UIFont systemFontOfSize:50];
        [degreeStr drawAtPoint:CGPointMake(50, 250) withAttributes:@{NSFontAttributeName:font_move, NSForegroundColorAttributeName: deepskyblue}];
        
        /*
        //回転角を示す棒
        CGContextRef rotateContext = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(rotateContext, 5);
        CGContextMoveToPoint(rotateContext, center.x, center.y);
        float radian = degree / 180 * M_PI;
        radian = radian * (-1);
        float rx = center.x * cosf(radian) - (center.y - 200) * sinf(radian);
        float ry = center.x * sinf(radian) + (center.y - 200) * cosf(radian);
        rx = center.x + rx;
        ry = center.y + ry;
        CGContextAddLineToPoint(rotateContext, rx, ry);
        CGContextStrokePath(rotateContext);
        */
        
        //円描画
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 5.0);
        //UIColor *color = [UIColor orangeColor];
        CGContextSetStrokeColorWithColor(context, [deepskyblue CGColor]);
        CGContextStrokeEllipseInRect(context, CGRectMake(center.x - 150, center.y - 150, 300, 300));
        
        
        //固定点の位置
        //UIFont *font2 = [UIFont systemFontOfSize:40];
        NSValue *value1 = [curr_fixedpointsPosi objectAtIndex:0];
        CGPoint curr_fixedPoint1 = [value1 CGPointValue];
        NSValue *value2 = [curr_fixedpointsPosi objectAtIndex:1];
        CGPoint curr_fixedPoint2 = [value2 CGPointValue];
        NSValue *value3 = [curr_fixedpointsPosi objectAtIndex:2];
        CGPoint curr_fixedPoint3 = [value3 CGPointValue];
        NSValue *value4 = [curr_fixedpointsPosi objectAtIndex:3];
        CGPoint curr_fixedPoint4 = [value4 CGPointValue];
        
        CGContextRef sEllipseContext = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(sEllipseContext, [deepskyblue CGColor]);
        //CGContextFillEllipseInRect(sEllipseContext, CGRectMake(curr_fixedPoint1.x-40, curr_fixedPoint1.y-20, 60, 60));
        //CGContextFillEllipseInRect(sEllipseContext, CGRectMake(curr_fixedPoint2.x-40, curr_fixedPoint2.y-20, 60, 60));
        //CGContextFillEllipseInRect(sEllipseContext, CGRectMake(curr_fixedPoint3.x-40, curr_fixedPoint3.y-20, 60, 60));
        //CGContextFillEllipseInRect(sEllipseContext, CGRectMake(curr_fixedPoint4.x-30, curr_fixedPoint4.y-20, 50, 50));
        
        /*
        [@"point1" drawAtPoint:curr_fixedPoint1 withAttributes:@{NSFontAttributeName:font2, NSForegroundColorAttributeName: deepskyblue}];
        [@"point2" drawAtPoint:curr_fixedPoint2 withAttributes:@{NSFontAttributeName:font2, NSForegroundColorAttributeName: deepskyblue}];
        [@"point3" drawAtPoint:curr_fixedPoint3 withAttributes:@{NSFontAttributeName:font2, NSForegroundColorAttributeName: deepskyblue}];
        [@"point4" drawAtPoint:curr_fixedPoint4 withAttributes:@{NSFontAttributeName:font2, NSForegroundColorAttributeName: deepskyblue}];
         */
        
    }
    
    //ID認識が成功した場合に描画
    if((self.capaRecog)&&(self.capaidNum > 0)){
        NSString *message = [NSString stringWithFormat: @"ID : NO.%d", self.capaidNum];
        CGPoint point = CGPointMake(50, 150);
        UIFont *font = [UIFont systemFontOfSize:50];
        [message drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: [UIColor orangeColor]}];
        
    }

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //4点以外の認識になったとき
    if([[event allTouches] count] != 4){
        //再度2点間の距離を計算
        self.calcReset = YES;
        self.capaRecog = NO;
        [self setNeedsDisplay];
        NSLog(@"not 4 touch point");
        return;
    }
    [self showTouchPoint:[event allTouches]];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //self.calcReset = YES;
    if([[event allTouches] count] != 4){
        return;
    }
    //[self showTouchPoint:[event allTouches]];
    
    //最寄りの点を探索
    [self findSamePoints:[event allTouches]];
    
    /*
    //前へ移動
    if(self.centGrav.y >= self.precentGrav.y + 50){
        NSLog(@"前へ移動");
    }else if(self.centGrav.y <= self.precentGrav.y - 50){
        NSLog(@"後ろへ移動");
    }
    */
}


- (void)showTouchPoint:(NSSet *)allTouches{
    
    //配列に保存
    self.touchObjects = [allTouches allObjects];
    
    //描画
    //[self setNeedsDisplay];
    
    if(self.calcReset){
        //距離
        [self calcDistance];
    }
}


//固定点と中央点を求める
- (void)calcDistance{
    NSLog(@"calcDistance");
    
    //手順
    //①fixP1とfixP2 (対角線上にある固定点) を求める
    //②fixP3 (3点目の固定点) を求める
    
    //最大2点間距離 = fixP1・fixP2距離
    float maxDis = 0;
    
    //固定点 (要素番号)
    int fixP1_ind = 0;
    int fixP2_ind = 0;
    int fixP3_ind = 0;
    
    //中央の可変点 (要素番号)
    int cenP_ind = 0;
    
    
    //①fixP1とfixP2を探す
    for(int i = 0; i < 4; i++){
        for(int j = 0; j < 4; j++){
            //全ての2点間距離を計算
            if(i != j){
                UITouch *tobj1 = [self.touchObjects objectAtIndex:i];
                UITouch *tobj2 = [self.touchObjects objectAtIndex:j];
                CGPoint loc1 = [tobj1 locationInView:self];
                CGPoint loc2 = [tobj2 locationInView:self];
                
                float disX = pow((loc1.x - loc2.x), 2); //xの差分を2乗
                float disY = pow((loc1.y - loc2.y), 2); //yの差分を2乗
                float dis = sqrt(disX + disY); //2点間の距離を求める
                
                //最大2点間距離
                if(dis > maxDis){
                    maxDis = dis;
                    fixP1_ind = i;
                    fixP2_ind = j;
                    fixP1_posi = loc1;
                    fixP2_posi = loc2;
                }
            }
        }
    }

    //fixP1とfixP2の座標を保存（現在）
    if([curr_fixedpointsPosi count] >= 4){
        [curr_fixedpointsPosi replaceObjectAtIndex:0 withObject:[NSValue valueWithCGPoint:fixP1_posi]];
        [curr_fixedpointsPosi replaceObjectAtIndex:1 withObject:[NSValue valueWithCGPoint:fixP2_posi]];
    }else{
        [curr_fixedpointsPosi insertObject:[NSValue valueWithCGPoint:fixP1_posi] atIndex:0];
        [curr_fixedpointsPosi insertObject:[NSValue valueWithCGPoint:fixP2_posi] atIndex:1];
    }
    
    //fixP1とfixP2の座標を保存（以前）
    if([prev_fixedpointsPosi count] >= 4){
        [prev_fixedpointsPosi replaceObjectAtIndex:0 withObject:[NSValue valueWithCGPoint:fixP1_posi]];
        [prev_fixedpointsPosi replaceObjectAtIndex:1 withObject:[NSValue valueWithCGPoint:fixP2_posi]];
    }else{
        [prev_fixedpointsPosi insertObject:[NSValue valueWithCGPoint:fixP1_posi] atIndex:0];
        [prev_fixedpointsPosi insertObject:[NSValue valueWithCGPoint:fixP2_posi] atIndex:1];
    }
    NSLog(@"固定点2点：(%.1f, %.1f)と(%.1f, %.1f)", fixP1_posi.x, fixP1_posi.y, fixP2_posi.x, fixP2_posi.y);
    
    
    //②fixP3を探す
    for(int i = 0; i < 4; i++){
        //残り2点の中から
        if((i != fixP1_ind)&&(i != fixP2_ind)){
            //fixP1との距離を調べる
            UITouch *tobj1 = [self.touchObjects objectAtIndex:fixP1_ind]; //fixP1
            UITouch *tobj3 = [self.touchObjects objectAtIndex:i]; //調べる点
            CGPoint loc1 = [tobj1 locationInView:self];
            CGPoint loc3 = [tobj3 locationInView:self]; //調べる点
            
            float disX = pow((loc1.x - loc3.x), 2);
            float disY = pow((loc1.y - loc3.y), 2);
            float dis = sqrt(disX + disY); //2点間の距離
            dis = (dis / 132) * 2.54; //px → cm 変換
            
            //fixP1との距離が特定の数値のとき
            if((dis >= 2.0)&&(dis <= 4.0)){
                NSLog(@"dis = %.1fcm", dis);
                
                //fixP2との距離を調べる
                UITouch *tobj2 = [self.touchObjects objectAtIndex:fixP2_ind]; //fixP2
                CGPoint loc2 = [tobj2 locationInView:self];
                
                float disX = pow((loc2.x - loc3.x), 2);
                float disY = pow((loc2.y - loc3.y), 2);
                dis = sqrt(disX + disY); //2点間の距離
                dis = (dis / 132) * 2.54; //px → cm 変換
                
                NSLog(@"dis = %.1fcm", dis);
                
                //fixP2との距離が特定の数値のとき
                if((dis >= 2.0)&&(dis <= 4.0)){
                    fixP3_ind = i;
                    fixP3_posi = loc3; //求めたfixP3
                    
                    //fixP2-fixP3間の距離を保存 → 後で，fixP2-cenP間の距離と比較
                    dis_fp2fp3 = dis;
    
                    //fixP3の座標を保存（現在）
                    if([curr_fixedpointsPosi count] >= 4){
                        [curr_fixedpointsPosi replaceObjectAtIndex:2 withObject:[NSValue valueWithCGPoint:fixP3_posi]];
                    }else{
                        [curr_fixedpointsPosi insertObject:[NSValue valueWithCGPoint:fixP3_posi] atIndex:2];
                    }
                    //fixP3の座標を保存（以前）
                    if([prev_fixedpointsPosi count] >= 4){
                        [prev_fixedpointsPosi replaceObjectAtIndex:2 withObject:[NSValue valueWithCGPoint:fixP3_posi]];
                    }else{
                        [prev_fixedpointsPosi insertObject:[NSValue valueWithCGPoint:fixP3_posi] atIndex:2];
                    }
                    NSLog(@"残りの固定点：(%.1f, %.1f)", fixP3_posi.x, fixP3_posi.y);
                    
                    
                    //中央の可変点cenPを求める
                    for(int i = 0; i < 4; i++){
                        if((i != fixP1_ind)&&(i != fixP2_ind)&&(i != fixP3_ind)){
                            cenP_ind = i;
                            UITouch *tobj4 = [self.touchObjects objectAtIndex:cenP_ind]; //cenP
                            cenP_posi = [tobj4 locationInView:self];
                            
                            NSLog(@"中央点：(%.1f, %.1f)", cenP_posi.x, cenP_posi.y);
                        }
                    }
                    
                    //cenPの座標を保存（現在）
                    if([curr_fixedpointsPosi count] >= 4){
                        [curr_fixedpointsPosi replaceObjectAtIndex:3 withObject:[NSValue valueWithCGPoint:cenP_posi]];
                    }else{
                        [curr_fixedpointsPosi insertObject:[NSValue valueWithCGPoint:cenP_posi] atIndex:3];
                    }
                    //cenPの座標を保存（以前）
                    if([prev_fixedpointsPosi count] >= 4){
                        [prev_fixedpointsPosi replaceObjectAtIndex:3 withObject:[NSValue valueWithCGPoint:cenP_posi]];
                    }else{
                        [prev_fixedpointsPosi insertObject:[NSValue valueWithCGPoint:cenP_posi] atIndex:3];
                    }
                    
                    //cenPとfixP3を交換
                    float disX = pow((loc2.x - cenP_posi.x), 2);
                    float disY = pow((loc2.y - cenP_posi.y), 2);
                    dis = sqrt(disX + disY); //2点間の距離
                    dis = (dis / 132) * 2.54; //px → cm 変換
                    dis_fp2cenP = dis;
                    if(dis_fp2cenP > dis_fp2fp3){
                        [curr_fixedpointsPosi exchangeObjectAtIndex:2 withObjectAtIndex:3];
                        [prev_fixedpointsPosi exchangeObjectAtIndex:2 withObjectAtIndex:3];
                    }
                    
                    //静電マーカーの中心
                    [self calcCenter:fixP1_posi fixedPoints2:fixP2_posi];
                    
                    //静電マーカーの中心座標を更新
                    prev_center = center;
                    sumDistance = CGPointMake(0, 0);
                    
                    
                    //マーカーとして認識
                    [self didRecognition];
                    
                    //角度を測定 + fixP1とfixP2を判別
                    [self calcAngle:fixP1_posi fixedPoints2:fixP2_posi fixedPoints3:fixP3_posi centerPoint:cenP_posi];
                    
                    
                    //中央の可変点からの距離を求める → ID判別
                    //[self calcDistancesFromRelativePoint];
                    
                    NSValue *pValue1 = [curr_fixedpointsPosi objectAtIndex:0];
                    fixP1_posi = [pValue1 CGPointValue];
                    
                    NSValue *pValue2 = [curr_fixedpointsPosi objectAtIndex:1];
                    fixP2_posi = [pValue2 CGPointValue];
                    
                    NSValue *pValue3 = [curr_fixedpointsPosi objectAtIndex:2];
                    fixP3_posi = [pValue3 CGPointValue];
                    
                    NSValue *cValue = [curr_fixedpointsPosi objectAtIndex:3];
                    cenP_posi = [cValue CGPointValue];
                    
                    
                    //fixP1・cenP間の距離
                    float dis1X = pow((cenP_posi.x - fixP1_posi.x), 2);
                    float dis1Y = pow((cenP_posi.y - fixP1_posi.y), 2);
                    dis1 = sqrt(dis1X + dis1Y);
                    dis1 = (dis1 / 132) * 2.54; //px → cm 変換
                    NSLog(@"dis1 (%@)と中央点の距離 = %.1fcm", NSStringFromCGPoint(fixP1_posi), dis1);
                    
                    //fixP2・cenP間の距離
                    float dis2X = pow((cenP_posi.x - fixP2_posi.x), 2);
                    float dis2Y = pow((cenP_posi.y - fixP2_posi.y), 2);
                    dis2 = sqrt(dis2X + dis2Y);
                    dis2 = (dis2 / 132) * 2.54; //px → cm 変換
                    NSLog(@"dis2 (%@)と中央点の距離 = %.1fcm", NSStringFromCGPoint(fixP2_posi), dis2);
                    
                    //fixP3・cenP間の距離
                    float dis3X = pow((cenP_posi.x - fixP3_posi.x), 2);
                    float dis3Y = pow((cenP_posi.y - fixP3_posi.y), 2);
                    dis3 = sqrt(dis3X + dis3Y);
                    dis3 = (dis3 / 132) * 2.54; //px → cm 変換
                    NSLog(@"dis3 (%@)と中央点の距離 = %.1fcm", NSStringFromCGPoint(fixP3_posi), dis3);
                    
                    
                    //IDの判別
                    [self identify:dis1 distance2:dis2 distance3:dis3];
                    
                    /*
                    float d1 = dis1;
                    float d2 = dis2;
                    float d3 = dis3;
                    
                    NSLog(@"d1 = %.1fcm", d1);
                    NSLog(@"d3 = %.1fcm", d3);
                    NSLog(@"d2 = %.1fcm", d2);
                    
                    self.capaidNum = 0;
                    
                    //Marker NO.1
                    if( ((d1 >= 1.0)&&(d1 <= 1.7)) && ((d3 >= 2.0)&&(d3 <= 2.6)) ){
                        NSLog(@"このマーカーはNO.1");
                        self.capaidNum = 1;
                    }
                    
                    //Marker NO.2
                    if( ((d1 >= 1.5)&&(d1 <= 2.1)) && ((d3 >= 2.2)&&(d3 <= 2.9)) ){
                        if((d2 >= 2.3)&&(d2 <= 2.9)){
                            NSLog(@"このマーカーはNO.2");
                            self.capaidNum = 2;
                        }
                    }
                    
                    //Marker NO.3
                    if( ((d1 >= 1.9)&&(d1 <= 2.6)) && ((d3 >= 2.6)&&(d3 <= 3.3)) ){
                        NSLog(@"このマーカーはNO.3");
                        self.capaidNum = 3;
                    }
                    
                    //Marker NO.4
                    if( ((d1 >= 1.5)&&(d1 <= 2.1)) && ((d3 >= 1.4)&&(d3 <= 2.0)) ){
                        NSLog(@"このマーカーはNO.4");
                        self.capaidNum = 4;
                    }
                    
                    //Marker NO.5
                    if( ((d1 >= 1.8)&&(d1 <= 2.4)) && ((d3 >= 1.8)&&(d3 <= 2.4)) ){
                        if((d2 >= 1.8)&&(d2 <= 2.4)){
                            NSLog(@"このマーカーはNO.5");
                            self.capaidNum = 5;
                        }
                    }
                    
                    //Marker NO.6
                    if( ((d1 >= 2.3)&&(d1 <= 2.9)) && ((d3 >= 2.2)&&(d3 <= 2.8)) ){
                        NSLog(@"このマーカーはNO.6");
                        self.capaidNum = 6;
                    }
                    
                    //Marker NO.7
                    if( ((d1 >= 2.0)&&(d1 <= 2.6)) && ((d3 >= 1.0)&&(d3 <= 1.6)) ){
                        NSLog(@"このマーカーはNO.7");
                        self.capaidNum = 7;
                    }
                    
                    //Marker NO.8
                    if( ((d1 >= 2.3)&&(d1 <= 2.9)) && ((d3 >= 1.4)&&(d3 <= 2.0)) ){
                        NSLog(@"このマーカーはNO.8");
                        self.capaidNum = 8;
                    }
                    
                    //Marker NO.9
                    if( ((d1 >= 2.7)&&(d1 <= 3.3)) && ((d3 >= 2.0)&&(d3 <= 2.6)) ){
                        NSLog(@"このマーカーはNO.9");
                        self.capaidNum = 9;
                    }
                     */
                    
                    //描画
                    [self setNeedsDisplay];
                    
                    break; //中央点が求まったので, 探索終了
                }else{
                    self.capaRecog = NO;
                }
            }else{
                self.capaRecog = NO;
            }
        }
    }//②fixP3を探す
    
    //一度限りの実行
    self.calcReset = NO;
}


//同一の固定点を探す(マーカーがドラッグされた時)
- (void)findSamePoints:(NSSet *)allTouches{
    //NSLog(@"findSamePoints");
    
    //配列に保存
    self.touchObjects = [allTouches allObjects];
    
    
    //保存した3つの固定点について、同一固定点をタッチオブジェクトの中から見つける
    for(int j = 0; j < 4; j++){
        //保存した固定点の座標を復元
        NSValue *value = [prev_fixedpointsPosi objectAtIndex:j];
        CGPoint pre_loc = [value CGPointValue];
        
        float minDis = MAXFLOAT;
        int pointIndex = 0;
        CGPoint pointLocation = CGPointMake(0, 0);
        
        for(int i = 0; i < 4; i++){
            //タッチオブジェクトの座標を取り出す
            UITouch *tobj = [self.touchObjects objectAtIndex:i];
            CGPoint loc = [tobj locationInView:self];
            
            float disX = pow((loc.x - pre_loc.x), 2);
            float disY = pow((loc.y - pre_loc.y), 2);
            float dis = sqrt(disX + disY); //2点間の距離
            
            //最短2点間距離
            if(dis < minDis){
                minDis = dis;
                pointIndex = i; //i番目のタッチオブジェクトが同一点である
                pointLocation = loc; //タッチオブジェクトの座標を控えておく
            }
        }
        
        //NSLog(@"curr_fixedpointsPosi : %@", [curr_fixedpointsPosi description]);
        
        [curr_fixedpointsPosi replaceObjectAtIndex:j withObject:[NSValue valueWithCGPoint:pointLocation]];
        [prev_fixedpointsPosi replaceObjectAtIndex:j withObject:[NSValue valueWithCGPoint:pointLocation]];
        
        minDis = (minDis / 132) * 2.54;
        //NSLog(@"最短距離：%.2lfcm,", minDis);
        //NSLog(@"%d番目のタッチオブジェクト,", pointIndex);
    }
    
    //中心の座標を更新
    CGPoint fp1 = [[curr_fixedpointsPosi objectAtIndex:0] CGPointValue];
    CGPoint fp2 = [[curr_fixedpointsPosi objectAtIndex:1] CGPointValue];
    CGPoint fp3 = [[curr_fixedpointsPosi objectAtIndex:2] CGPointValue];
    CGPoint cp = [[curr_fixedpointsPosi objectAtIndex:3] CGPointValue];
    [self calcCenter:fp1 fixedPoints2:fp2];
    
    //動作を判別
    [self trackMove];
    
    //角度を測定
    [self calcAngle:fp1 fixedPoints2:fp2 fixedPoints3:fp3 centerPoint:cp];
    
    [self setNeedsDisplay];
}


//マーカー認識完了
- (void)didRecognition{
    //マーカーとして認識
    self.capaRecog = YES;
    
    [self.capaRecogSound play];
}


//中央の可変点からの距離を求める × 4つ
- (void)calcDistancesFromRelativePoint{
    NSValue *pValue1 = [curr_fixedpointsPosi objectAtIndex:0];
    fixP1_posi = [pValue1 CGPointValue];
    
    NSValue *pValue2 = [curr_fixedpointsPosi objectAtIndex:1];
    fixP2_posi = [pValue2 CGPointValue];
    
    NSValue *pValue3 = [curr_fixedpointsPosi objectAtIndex:2];
    fixP3_posi = [pValue3 CGPointValue];
    
    NSValue *cValue = [curr_fixedpointsPosi objectAtIndex:3];
    cenP_posi = [cValue CGPointValue];
    
    
    //fixP1・cenP間の距離
    float dis1X = pow((cenP_posi.x - fixP1_posi.x), 2);
    float dis1Y = pow((cenP_posi.y - fixP1_posi.y), 2);
    dis1 = sqrt(dis1X + dis1Y);
    dis1 = (dis1 / 132) * 2.54; //px → cm 変換
    NSLog(@"dis1 (%@)と中央点の距離 = %.1fcm", NSStringFromCGPoint(fixP1_posi), dis1);
    
    //fixP2・cenP間の距離
    float dis2X = pow((cenP_posi.x - fixP2_posi.x), 2);
    float dis2Y = pow((cenP_posi.y - fixP2_posi.y), 2);
    dis2 = sqrt(dis2X + dis2Y);
    dis2 = (dis2 / 132) * 2.54; //px → cm 変換
    NSLog(@"dis2 (%@)と中央点の距離 = %.1fcm", NSStringFromCGPoint(fixP2_posi), dis2);
    
    //fixP3・cenP間の距離
    float dis3X = pow((cenP_posi.x - fixP3_posi.x), 2);
    float dis3Y = pow((cenP_posi.y - fixP3_posi.y), 2);
    dis3 = sqrt(dis3X + dis3Y);
    dis3 = (dis3 / 132) * 2.54; //px → cm 変換
    NSLog(@"dis3 (%@)と中央点の距離 = %.1fcm", NSStringFromCGPoint(fixP3_posi), dis3);
    
    //IDの判別
    [self identify:dis1 distance2:dis2 distance3:dis3];
}


//マーカのID判別
- (void)identify:(float)d1 distance2:(float)d2 distance3:(float)d3{
    NSLog(@"d1 = %.2fcm", d1);
    NSLog(@"d3 = %.2fcm", d3);
    NSLog(@"d2 = %.2fcm", d2);
    
    self.capaidNum = 0;
    
    [self checkId1:d1 distance2:d2 distance3:d3];
    //[self checkId2:d1 distance2:d2 distance3:d3];
    [self checkId3:d1 distance2:d2 distance3:d3];
    //[self checkId4:d1 distance2:d2 distance3:d3];
    [self checkId5:d1 distance2:d2 distance3:d3];
    //[self checkId6:d1 distance2:d2 distance3:d3];
    [self checkId7:d1 distance2:d2 distance3:d3];
    //[self checkId8:d1 distance2:d2 distance3:d3];
    [self checkId9:d1 distance2:d2 distance3:d3];
}

- (void)checkId1:(float)d1 distance2:(float)d2 distance3:(float)d3{
    //Marker NO.1
    if( ((d1 >= 1.0)&&(d1 <= 1.7)) && ((d3 >= 1.8)&&(d3 <= 2.6)) ){
        NSLog(@"このマーカーはNO.1");
        self.capaidNum = 1;
    }
    //[self checkId2:d1 distance2:d2 distance3:d3];
}

- (void)checkId2:(float)d1 distance2:(float)d2 distance3:(float)d3{
    //Marker NO.2
    if( ((d1 >= 1.5)&&(d1 <= 2.1)) && ((d3 >= 2.2)&&(d3 <= 2.9)) ){
        if((d2 >= 2.3)&&(d2 <= 2.9)){
            NSLog(@"このマーカーはNO.2");
            self.capaidNum = 2;
        }
    }
    //[self checkId3:d1 distance2:d2 distance3:d3];
}

- (void)checkId3:(float)d1 distance2:(float)d2 distance3:(float)d3{
    //Marker NO.3
    if( ((d1 >= 1.8)&&(d1 <= 2.6)) && ((d3 >= 2.5)&&(d3 <= 3.3)) ){
        NSLog(@"このマーカーはNO.3");
        self.capaidNum = 3;
    }
    //[self checkId4:d1 distance2:d2 distance3:d3];
}

- (void)checkId4:(float)d1 distance2:(float)d2 distance3:(float)d3{
    //Marker NO.4
    if( ((d1 >= 1.4)&&(d1 <= 2.1)) && ((d3 >= 1.4)&&(d3 <= 2.0)) ){
        NSLog(@"このマーカーはNO.4");
        self.capaidNum = 4;
    }
    //[self checkId5:d1 distance2:d2 distance3:d3];
}

- (void)checkId5:(float)d1 distance2:(float)d2 distance3:(float)d3{
    //Marker NO.5
    if( ((d1 > 1.7)&&(d1 <= 2.4)) && ((d3 >= 1.8)&&(d3 <= 2.4)) ){
        if((d2 >= 1.8)&&(d2 <= 2.4)){
            NSLog(@"このマーカーはNO.5");
            self.capaidNum = 5;
        }
    }
    //[self checkId6:d1 distance2:d2 distance3:d3];
}

- (void)checkId6:(float)d1 distance2:(float)d2 distance3:(float)d3{
    //Marker NO.6
    if( ((d1 > 2.1)&&(d1 <= 2.9)) && ((d3 > 2.1)&&(d3 <= 2.8)) ){
        NSLog(@"このマーカーはNO.6");
        self.capaidNum = 6;
    }
    //[self checkId7:d1 distance2:d2 distance3:d3];
}

//(d >= 1.6), (d3 < 1.7)
- (void)checkId7:(float)d1 distance2:(float)d2 distance3:(float)d3{
    //Marker NO.7
    if( ((d1 >= 1.6)&&(d1 <= 2.6)) && ((d3 >= 1.0)&&(d3 <= 1.7)) ){
        NSLog(@"このマーカーはNO.7");
        self.capaidNum = 7;
    }
    //[self checkId8:d1 distance2:d2 distance3:d3];
}

- (void)checkId8:(float)d1 distance2:(float)d2 distance3:(float)d3{
    //Marker NO.8
    if( ((d1 >= 2.3)&&(d1 <= 2.9)) && ((d3 >= 1.4)&&(d3 <= 2.0)) ){
        NSLog(@"このマーカーはNO.8");
        self.capaidNum = 8;
    }
    //[self checkId9:d1 distance2:d2 distance3:d3];
}

- (void)checkId9:(float)d1 distance2:(float)d2 distance3:(float)d3{
    //Marker NO.9
    if( ((d1 > 2.3)&&(d1 <= 3.3)) && ((d3 > 1.9)&&(d3 <= 2.8)) ){
        NSLog(@"このマーカーはNO.9");
        self.capaidNum = 9;
    }
}

//静電マーカーの中央を求める
- (void)calcCenter:(CGPoint)fp1 fixedPoints2:(CGPoint)fp2{
    //対角線上にある2つの固定点から求める
    center.x = fp1.x + (fp2.x - fp1.x) / 2;
    center.y = fp1.y + (fp2.y - fp1.y) / 2;
    
    //距離の絶対値をとる
    if(center.x < 0){
        center.x = center.x * (-1);
    }
    if(center.y < 0){
        center.y = center.y * (-1);
    }
}

//（前後左右の）動作判別を行う
- (void)trackMove{
    
    CGPoint moveDistance = CGPointMake(center.x - prev_center.x, center.y - prev_center.y);
    moveDistance.x = (moveDistance.x / 132) * 2.54; //cmに変換
    moveDistance.y = (moveDistance.y / 132) * 2.54; //cmに変換
    
    sumDistance.x = sumDistance.x + moveDistance.x; //移動距離の総和
    sumDistance.y = sumDistance.y + moveDistance.y;
    
    //NSLog(@"sumDistance.x = %.2lf", sumDistance.x);
    //NSLog(@"sumDistance.y = %.2lf", sumDistance.y);

    moveFlag = NO; //前後左右へ移動したかどうか → 描画時の手がかり
    
    //1cm以上移動した時に動作検知
    if(sumDistance.x > 0){
        if(sumDistance.x > 1){
            //NSLog(@"右へ動いた");
            //NSLog(@"sumDistance.x = %.2lfcm", sumDistance.x);
            moveState = @"→";
            moveFlag = YES;
            sumDistance.y = 0; //y軸移動距離の初期化
        }
    }else if(sumDistance.x < 0){
        if(sumDistance.x < -1){
            //NSLog(@"左へ動いた");
            //NSLog(@"sumDistance.x = %.2lfcm", sumDistance.x);
            moveState = @"←";
            moveFlag = YES;
            sumDistance.y = 0; //y軸移動距離の初期化
        }
    }
    
    if(sumDistance.y > 0){
        if(sumDistance.y > 1){
            //NSLog(@"後ろへ動いた");
            //NSLog(@"sumDistance.y = %.2lfcm", sumDistance.y);
            moveState = @"↓";
            moveFlag = YES;
            sumDistance.x = 0; //x軸移動距離の初期化
        }
    }else if(sumDistance.y < 0){
        if(sumDistance.y < -1){
            //NSLog(@"前へ動いた");
            //NSLog(@"sumDistance.y = %.2lfcm", sumDistance.y);
            moveState = @"↑";
            moveFlag = YES;
            sumDistance.x = 0; //x軸移動距離の初期化
        }
    }
    
    prev_center = center;
}

//マーカーの回転角度を求める + 固定点1と固定点2を判別
- (void)calcAngle:(CGPoint)fp1 fixedPoints2:(CGPoint)fp2 fixedPoints3:(CGPoint)fp3 centerPoint:(CGPoint)cp{
    //固定点と中央点の位置関係 → マーカーの向きを4つに分類
    if((fp3.x >= cp.x)&&(fp3.y >= cp.y)){
        //NSLog(@"回転角 0°");
        if(fp1.y > fp2.y){
            //int index = fixP1_ind;
            //fixP1_ind = fixP2_ind;
            //fixP2_ind = index; //P1とP2 要素番号の入れ替え
            
            CGPoint position = fp1;
            fp1 = fp2;
            fp2 = position; //P1とP2 要素番号の入れ替え
            [curr_fixedpointsPosi exchangeObjectAtIndex:0 withObjectAtIndex:1];
            [prev_fixedpointsPosi exchangeObjectAtIndex:0 withObjectAtIndex:1];
            NSLog(@"exchange fp1 and fp2");
        }
        
    }else if((fp3.x >= cp.x)&&(fp3.y <= cp.y)){
        //NSLog(@"回転角 90°");
        if(fp1.y > fp2.y){
            //int index = fixP1_ind;
            //fixP1_ind = fixP2_ind;
            //fixP2_ind = index;
            
            CGPoint position = fp1;
            fp1 = fp2;
            fp2 = position;
            [curr_fixedpointsPosi exchangeObjectAtIndex:0 withObjectAtIndex:1];
            [prev_fixedpointsPosi exchangeObjectAtIndex:0 withObjectAtIndex:1];
            NSLog(@"exchange fp1 and fp2");
        }
        
    }else if((fp3.x <= cp.x)&&(fp3.y <= cp.y)){
        //NSLog(@"回転角 180°");
        if(fp1.y < fp2.y){
            //int index = fixP1_ind;
            //fixP1_ind = fixP2_ind;
            //fixP2_ind = index;
            
            CGPoint position = fp1;
            fp1 = fp2;
            fp2 = position;
            [curr_fixedpointsPosi exchangeObjectAtIndex:0 withObjectAtIndex:1];
            [prev_fixedpointsPosi exchangeObjectAtIndex:0 withObjectAtIndex:1];
            NSLog(@"exchange fp1 and fp2");
        }
        
    }else if((fp3.x <= cp.x)&&(fp3.y >= cp.y)){
        //NSLog(@"回転角 270°");
        if(fp1.y < fp2.y){
            //int index = fixP1_ind;
            //fixP1_ind = fixP2_ind;
            //fixP2_ind = index;
            
            CGPoint position = fp1;
            fp1 = fp2;
            fp2 = position;
            [curr_fixedpointsPosi exchangeObjectAtIndex:0 withObjectAtIndex:1];
            [prev_fixedpointsPosi exchangeObjectAtIndex:0 withObjectAtIndex:1];
            NSLog(@"exchange fp1 and fp2");
        }

    }
    
    //角度の計算
    float y = fp1.y - fp3.y;
    float x = fp1.x - fp3.x;
    float radian = atan2f(y, x);
    
    radian = radian * (-1); //角度の回転方向を反転
    degree = (radian / (2*M_PI)) * 360 + 180; // -180~180° → 0~360°．
    degree = degree + 90; //0~360° → 90~450°（90°足して0°が来る向きを合わせる．）
    degree = fmodf(degree, 360);
    
    //NSLog(@"radian = %lf", radian);
    //NSLog(@"degree = %lf", degree);
}


@end
