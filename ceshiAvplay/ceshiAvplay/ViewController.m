//
//  ViewController.m
//  ceshiAvplay
//
//  Created by fls on 2019/5/31.
//  Copyright © 2019年 fls. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LQPlayVideoViewController.h"
#import "LQPlayAVTool.h"
#import "FlsAudioPlayer.h"

@interface ViewController ()
@property(nonatomic,strong) AVPlayer * Aplayer;
@property(nonatomic,strong) FlsAudioPlayer * audioPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    http://res.inoot.cn/d5/voice/2019/06/03/162665e0-becd-499b-8bd7-6104c81b1acf.m4a
//    NSString * urlStr = @"http://res.inoot.cn/d5/voice/2019/05/29/3acf768a-2606-4cc3-885c-a4ea70d64066.mp3";
    NSString * urlStr = @"http://res.inoot.cn/d5/voice/2019/06/03/162665e0-becd-499b-8bd7-6104c81b1acf.m4a";

//    NSURL * url  = [NSURL URLWithString:urlStr];
//    AVPlayerItem * songItem = [[AVPlayerItem alloc]initWithURL:url];
//    AVPlayer * player = [[AVPlayer alloc]initWithPlayerItem:songItem];
//    player.muted = NO;
//    player.volume = 1.0;
//    self.Aplayer = player;
//    NSError *error = nil;
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error];

//    [player play];
    self.audioPlayer = [[FlsAudioPlayer alloc] init];
    self.audioPlayer.url = urlStr;
    self.audioPlayer.audioPlayEndBlock = ^{
        NSLog(@"播放结束");
    };
    
}

- (IBAction)clickButton:(id)sender {
//    AVPlayerItem * songItem = self.Aplayer.currentItem;
//    NSLog(@"%@",songItem);
//    [self.Aplayer play];
//    NSString * urlStr = @"http://res.inoot.cn/d5/voice/2019/05/29/3acf768a-2606-4cc3-885c-a4ea70d64066.mp3";
//    LQPlayVideoViewController *nextVc = [[LQPlayVideoViewController alloc] initWithVideoUrl:[NSURL URLWithString:urlStr] type:LQAVPlayTypeAudio];
//    nextVc.popTitles = @[];
//    nextVc.title = @"测试语音";
//    nextVc.VCtype = @"18";
//    [self presentViewController:nextVc animated:YES completion:nil];
    [self.audioPlayer play];
}




@end
