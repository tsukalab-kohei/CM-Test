//
//  ViewController.h
//  ARMetaioTest
//
//  Created by 池田昂平 on 2014/10/20.
//  Copyright (c) 2014年 池田昂平. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import "MetaioSDKViewController.h"
#import "EAGLView.h"
#import "ARView.h"

@interface ViewController : MetaioSDKViewController

@property AVAudioPlayer *recogSound;
@property ARView *arview;

@end
