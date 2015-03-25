//
//  TouchView.m
//  TouchTest2
//
//  Created by 池田昂平 on 2014/10/15.
//  Copyright (c) 2014年 池田昂平. All rights reserved.
//

#import "TouchView.h"

@implementation TouchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.multipleTouchEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        calcReset = YES;
        //markerRecog = NO;
        idNum = 0;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"recog" ofType:@"wav"];
        NSURL *url = [NSURL fileURLWithPath:path];
        self.recogSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    //現在のタッチ数の表示
    NSInteger tCount = [touchObjects count];
    NSString *countText = [NSString stringWithFormat: @"タッチ数: %ld", (long)tCount];
    CGPoint point = CGPointMake(50, 50);
    UIFont *font = [UIFont systemFontOfSize:20];
    [countText drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    for (UITouch *touch in touchObjects){
        CGPoint location = [touch locationInView:self];
        //NSLog(@"x:%f y:%f", location.x, location.y);
        
        
        //接地面積の取得
        CGFloat majorRadi = [[touch valueForKey:@"pathMajorRadius"] floatValue];
        NSLog(@"接地面積: %f", majorRadi);
        
        /*
        //円の描画
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIColor *color = [UIColor yellowColor];
        CGContextSetFillColor(context, CGColorGetComponents(color.CGColor));
        CGContextFillEllipseInRect(context, CGRectMake(location.x, location.y, 30, 30));
        */
        
        //テキスト表示
        NSString *text = [NSString stringWithFormat: @"%0.1f, %0.1f, 接触面積：%0.1f", location.x, location.y, majorRadi];
        CGPoint point = CGPointMake(location.x, location.y);
        [text drawAtPoint:point withAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
    
    //マーカー認識が成功した場合に描画
    if(markerRecog){
        //メッセージ表示
        NSString *message = @"Marker recognition is sucess.";
        CGPoint point = CGPointMake(100, 150);
        UIFont *font = [UIFont systemFontOfSize:30];
        [message drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: [UIColor orangeColor]}];
        
            //円描画
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(context, 12.0);
            UIColor *color = [UIColor orangeColor];
            //UIColor *orangecolor = [UIColor colorWithRed:1.0 green:0.647 blue:0.0 alpha:1.0];
            //CGContextSetStrokeColor(context, CGColorGetComponents(orangecolor.CGColor));
            CGContextSetStrokeColorWithColor(context, [color CGColor]);
            CGContextStrokeEllipseInRect(context, CGRectMake(center.x - 150, center.y - 150, 300, 300));
    }
    
    //ID認識が成功した場合に描画
    if((markerRecog)&&(idNum > 0)){
        NSString *message = [NSString stringWithFormat: @"Marker ID : NO.%d.", idNum];
        CGPoint point = CGPointMake(100, 200);
        UIFont *font = [UIFont systemFontOfSize:30];
        [message drawAtPoint:point withAttributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName: [UIColor blackColor]}];

    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    //4点以外の認識になったとき
    if([[event allTouches] count] != 4){
        //再度2点間の距離を計算
        calcReset = YES;
        markerRecog = NO;
        [self setNeedsDisplay];
        return;
    }
    [self showTouchPoint:[event allTouches]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([[event allTouches] count] != 4){
        return;
    }
    [self showTouchPoint:[event allTouches]];
}

- (void)showTouchPoint:(NSSet *)allTouches{
    
    //配列に保存
    touchObjects = [allTouches allObjects];
    
    //描画
    [self setNeedsDisplay];
    
    if(calcReset){
        //距離
        [self calcDistance];
    }

    /*
    //一度だけソートする
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self sort];
    });
     */
    
    
    //[self sort];
}

//固定点と中央点を求める
- (void)calcDistance{
    
    //手順
    //①fixP1とfixP2 (対角線上にある固定点) を求める
    //②fixP3 (3点目の固定点) を求める
    
    //最大2点間距離 = fixP1・fixP2距離
    float maxDis = 0;
    
    //固定点 (要素番号)
    int fixP1_ind = 0;
    int fixP2_ind = 0;
    int fixP3_ind = 0;
    
    //中央点 (要素番号)
    int cenP_ind = 0;
    
    //固定点 (x座標)
    CGPoint fixP1_posi;
    CGPoint fixP2_posi;
    CGPoint fixP3_posi;
    
    //中央点 (x座標)
    CGPoint cenP_posi;
    
    //①fixP1とfixP2を探す
    for(int i = 0; i < 4; i++){
        for(int j = 0; j < 4; j++){
            //全ての2点間距離を計算
            if(i != j){
                UITouch *tobj1 = [touchObjects objectAtIndex:i];
                UITouch *tobj2 = [touchObjects objectAtIndex:j];
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
                
                //NSLog(@"%d番目：(%.1f,%.1f)と(%.1f,%.1f)の距離 = %.1f", i, loc1.x, loc1.y, loc2.x, loc2.y, dis);
            }
        }
    }
    NSLog(@"固定点2点：(%.1f, %.1f)と(%.1f, %.1f)", fixP1_posi.x, fixP1_posi.y, fixP2_posi.x, fixP2_posi.y);
    
    //②fixP3を探す
    for(int i = 0; i < 4; i++){
        //残り2点の中から
        if((i != fixP1_ind)&&(i != fixP2_ind)){
            UITouch *tobj1 = [touchObjects objectAtIndex:fixP1_ind]; //fixP1
            UITouch *tobj3 = [touchObjects objectAtIndex:i]; //調べる点
            CGPoint loc1 = [tobj1 locationInView:self];
            CGPoint loc3 = [tobj3 locationInView:self];
            
            float disX = pow((loc1.x - loc3.x), 2);
            float disY = pow((loc1.y - loc3.y), 2);
            float dis = sqrt(disX + disY); //2点間の距離
            dis = (dis / 132) * 2.54; //px → cm 変換
            
            //NSLog(@"%d番目：(%.1f,%.1f)と(%.1f,%.1f)の距離 = %.1f", i, loc1.x, loc1.y, loc3.x, loc3.y, dis);
            
            //fixP1との距離が特定の数値のとき
            if((dis >= 2.0)&&(dis <= 4.0)){
                NSLog(@"dis = %.1fcm", dis);
                
                UITouch *tobj2 = [touchObjects objectAtIndex:fixP2_ind]; //fixP2
                CGPoint loc2 = [tobj2 locationInView:self];
                
                float disX = pow((loc2.x - loc3.x), 2);
                float disY = pow((loc2.y - loc3.y), 2);
                dis = sqrt(disX + disY); //2点間の距離
                dis = (dis / 132) * 2.54; //px → cm 変換
                
                NSLog(@"dis = %.1fcm", dis);
                
                //fixP2との距離が特定の数値のとき
                if((dis >= 2.0)&&(dis <= 4.0)){
                    fixP3_ind = i;
                    fixP3_posi = loc3;
                    NSLog(@"残りの固定点：(%.1f, %.1f)", fixP3_posi.x, fixP3_posi.y);
                    
                    //中央点を求める
                    for(int i = 0; i < 4; i++){
                        if((i != fixP1_ind)&&(i != fixP2_ind)&&(i != fixP3_ind)){
                            cenP_ind = i;
                            UITouch *tobj4 = [touchObjects objectAtIndex:cenP_ind]; //cenP
                            cenP_posi = [tobj4 locationInView:self];
                            
                            NSLog(@"中央点：(%.1f, %.1f)", cenP_posi.x, cenP_posi.y);
                        }
                    }
                    
                    //固定点と中央点の位置関係 → マーカーの向きを4つに分類
                    if((fixP3_posi.x >= cenP_posi.x)&&(fixP3_posi.y >= cenP_posi.y)){
                        NSLog(@"回転角 0°");
                        if(fixP1_posi.y > fixP2_posi.y){
                            int index = fixP1_ind;
                            fixP1_ind = fixP2_ind;
                            fixP2_ind = index; //P1とP2 要素番号の入れ替え
                            
                            CGPoint position = fixP1_posi;
                            fixP1_posi = fixP2_posi;
                            fixP2_posi = position; //P1とP2 要素番号の入れ替え
                        }
                        
                        center.x = fixP2_posi.x + (fixP1_posi.x - fixP2_posi.x) / 2;
                        center.y = fixP1_posi.y + (fixP2_posi.y - fixP1_posi.y) / 2;

                    }else if((fixP3_posi.x >= cenP_posi.x)&&(fixP3_posi.y <= cenP_posi.y)){
                        NSLog(@"回転角 90°");
                        if(fixP1_posi.y > fixP2_posi.y){
                            int index = fixP1_ind;
                            fixP1_ind = fixP2_ind;
                            fixP2_ind = index;
                            
                            CGPoint position = fixP1_posi;
                            fixP1_posi = fixP2_posi;
                            fixP2_posi = position;
                        }
                        
                        center.x = fixP1_posi.x + (fixP2_posi.x - fixP1_posi.x) / 2;
                        center.y = fixP1_posi.y + (fixP2_posi.y - fixP1_posi.y) / 2;
        
                    }else if((fixP3_posi.x <= cenP_posi.x)&&(fixP3_posi.y <= cenP_posi.y)){
                        NSLog(@"回転角 180°");
                        if(fixP1_posi.y < fixP2_posi.y){
                            int index = fixP1_ind;
                            fixP1_ind = fixP2_ind;
                            fixP2_ind = index;
                            
                            CGPoint position = fixP1_posi;
                            fixP1_posi = fixP2_posi;
                            fixP2_posi = position;
                        }
                        
                        center.x = fixP1_posi.x + (fixP2_posi.x - fixP1_posi.x) / 2;
                        center.y = fixP2_posi.y + (fixP1_posi.y - fixP2_posi.y) / 2;
                        
                    }else if((fixP3_posi.x <= cenP_posi.x)&&(fixP3_posi.y >= cenP_posi.y)){
                        NSLog(@"回転角 270°");
                        if(fixP1_posi.y < fixP2_posi.y){
                            int index = fixP1_ind;
                            fixP1_ind = fixP2_ind;
                            fixP2_ind = index;
                            
                            CGPoint position = fixP1_posi;
                            fixP1_posi = fixP2_posi;
                            fixP2_posi = position;
                        }
                        
                        center.x = fixP2_posi.x + (fixP1_posi.x - fixP2_posi.x) / 2;
                        center.y = fixP2_posi.y + (fixP1_posi.y - fixP2_posi.y) / 2;
                        
                    }
                    
                    //マーカーとして認識
                    [self didRecognition];
                    
                    //判別したfixP1, fixP2の座標
                    //NSLog(@"固定点①：%@", NSStringFromCGPoint(fixP1_posi));
                    //NSLog(@"固定点②：%@", NSStringFromCGPoint(fixP2_posi));
                    
                    
                    
                    //fixP1・cenP間の距離
                    float dis1X = pow((cenP_posi.x - fixP1_posi.x), 2);
                    float dis1Y = pow((cenP_posi.y - fixP1_posi.y), 2);
                    float dis1 = sqrt(dis1X + dis1Y);
                    dis1 = (dis1 / 132) * 2.54; //px → cm 変換
                    NSLog(@"dis1 (%@)と中央点の距離 = %.1fcm", NSStringFromCGPoint(fixP1_posi), dis1);
                    
                    //fixP2・cenP間の距離
                    float dis2X = pow((cenP_posi.x - fixP2_posi.x), 2);
                    float dis2Y = pow((cenP_posi.y - fixP2_posi.y), 2);
                    float dis2 = sqrt(dis2X + dis2Y);
                    dis2 = (dis2 / 132) * 2.54; //px → cm 変換
                    NSLog(@"dis2 (%@)と中央点の距離 = %.1fcm", NSStringFromCGPoint(fixP2_posi), dis2);
                    
                    //fixP3・cenP間の距離
                    float dis3X = pow((cenP_posi.x - fixP3_posi.x), 2);
                    float dis3Y = pow((cenP_posi.y - fixP3_posi.y), 2);
                    float dis3 = sqrt(dis3X + dis3Y);
                    dis3 = (dis3 / 132) * 2.54; //px → cm 変換
                    NSLog(@"dis3 (%@)と中央点の距離 = %.1fcm", NSStringFromCGPoint(fixP3_posi), dis3);
                    
                    [self identify:dis1 distance3:dis3];
                    
                    break; //中央点が求まったので, 探索終了
                }else{
                    markerRecog = NO;
                }
            }else{
                markerRecog = NO;
            }
        }
    }
    
    //一度限りの実行
    calcReset = NO;
}

//マーカー認識完了
- (void)didRecognition{
    //マーカーとして認識
    markerRecog = YES;
    
    [self.recogSound play];
    
    //AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, NULL, NULL);
}

//マーカのID判別
- (void)identify:(float)d1 distance3:(float)d3{
    NSLog(@"d1 = %.1fcm", d1);
    NSLog(@"d3 = %.1fcm", d3);
    
    idNum = 0;
    
    //Marker NO.1
    if( ((d1 >= 1.0)&&(d1 <= 1.6)) && ((d3 >= 2.0)&&(d3 <=  2.6)) ){
        NSLog(@"このマーカーはNO.1");
        idNum = 1;
    }
    
    //Marker NO.3
    if( ((d1 >= 2.0)&&(d1 <= 2.6)) && ((d3 >= 2.7)&&(d3 <= 3.3)) ){
        NSLog(@"このマーカーはNO.3");
        idNum = 3;
    }
    
    //Marker NO.4
    if( ((d1 >= 1.5)&&(d1 <= 2.1)) && ((d3 >= 1.4)&&(d3 <= 2.0)) ){
        NSLog(@"このマーカーはNO.4");
        idNum = 4;
    }
    
    //Marker NO.5
    if( ((d1 >= 1.8)&&(d1 <= 2.4)) && ((d3 >= 1.8)&&(d3 <= 2.4)) ){
        NSLog(@"このマーカーはNO.5");
        idNum = 5;
    }
    
    //Marker NO.6
    if( ((d1 >= 1.9)&&(d1 <= 2.5)) && ((d3 >= 2.2)&&(d3 <= 2.8)) ){
        NSLog(@"このマーカーはNO.6");
        idNum = 6;
    }
    
    //Marker NO.7
    if( ((d1 >= 2.0)&&(d1 <= 2.6)) && ((d3 >= 1.0)&&(d3 <= 1.6)) ){
        NSLog(@"このマーカーはNO.7");
        idNum = 7;
    }
    
    //Marker NO.8
    if( ((d1 >= 2.3)&&(d1 <= 2.9)) && ((d3 >= 1.4)&&(d3 <= 2.0)) ){
        NSLog(@"このマーカーはNO.8");
        idNum = 8;
    }
    
    //Marker NO.9
    if( ((d1 >= 2.7)&&(d1 <= 3.3)) && ((d3 >= 2.0)&&(d3 <= 2.6)) ){
        NSLog(@"このマーカーはNO.9");
        idNum = 9;
    }

}

/*
- (void)sort{
    int n = (int)[touchObjects count];
    
    //昇順のバブルソート
    for(int i = 0; i < n-1; i++){
        for(int j=n-1; j > i; j++){
            UITouch *tobj1 = [touchObjects objectAtIndex:0];
            UITouch *tobj2 = [touchObjects objectAtIndex:1];
            CGPoint loc1 = [tobj1 locationInView:self];
            CGPoint loc2 = [tobj2 locationInView:self];
            
            
            //x座標の値でソート
            if(loc1.x > loc2.x){
                UITouch *value = touchObjects[j-1];
                [touchObjects insertObject:tobj2 atIndex:j-1];
                [touchObjects insertObject:value atIndex:j];
            }
        }
    }
    

    NSLog(@"ソート終了");
    [self showLogTObj];
}
*/

//コンソールログで、全てのタッチオブジェクトの座標を表示
- (void)showLogTObj{
    for (UITouch *touch in touchObjects){
        CGPoint point = [touch locationInView:self];
        NSLog(@"x:%f, y:%f", point.x, point.y);
    }
    NSLog(@"allTouches count : %lu", (unsigned long)[touchObjects count]);
}

//向き固定のパターン
- (void)discrimPatt{
    /*
    NSInteger tObjSize = [touchObjects count];
    NSString *text;
    CGPoint point = CGPointMake(100, 100);
     */
    
    /*
    switch (tObjSize) {
        case 1:
            //text = @"パターン 1";
            //[text drawAtPoint:point withAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
            self.backgroundColor = [UIColor brownColor];
            break;
            
        case 2:
            //text = @"パターン 2";
            self.backgroundColor = [UIColor cyanColor];
            break;
            
        case 3:
            //text = @"パターン 3";
            self.backgroundColor = [UIColor grayColor];
            break;
            
        case 4:
            //text = @"パターン 4";
            self.backgroundColor = [UIColor greenColor];
            break;
            
        case 5:
            //text = @"パターン 5";
            self.backgroundColor = [UIColor orangeColor];
            break;
            
        default:
            self.backgroundColor = [UIColor purpleColor];
            break;
    }
    */
}

@end
