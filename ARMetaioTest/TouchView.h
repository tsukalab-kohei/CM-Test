//
//  TouchView.h
//  TouchTest2
//
//  Created by 池田昂平 on 2014/10/15.
//  Copyright (c) 2014年 池田昂平. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface TouchView : UIView{
    //CGPoint location;
    //NSInteger touchCount;
    //NSMutableArray *points;
    //NSMutableArray *touchObjects;
    NSArray *touchObjects;
    CGPoint center;
    BOOL calcReset;
    BOOL markerRecog;
    int idNum;
}

@property(nonatomic, readonly) CGFloat majorRadius;
@property AVAudioPlayer *recogSound;

- (void)drawRect:(CGRect)rect;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)showTouchPoint:(NSSet *)allTouches;
@end
