//
//  LQPlayVideoViewController.m
//  PlayVideoDemo
//
//  Created by 李磊 on 2017/4/27.
//  Copyright © 2017年 李磊www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQPlayAVTool.h"


@interface LQPlayVideoViewController : UIViewController

@property(nonatomic,copy) void(^selectedBlock)(NSInteger index);
@property(nonatomic,copy) void(^ClickShareBlock)(void);


- (instancetype)initWithVideoUrl:(NSURL *)url type:(LQAVPlayType)type;

- (instancetype)initWithVideoModels:(NSArray *)videoModels type:(LQAVPlayType)type;
/**
 弹出框数组
 */
@property(nonatomic,strong) NSArray *popTitles;

@property (nonatomic,assign) BOOL isNoOpen;
@property (nonatomic,assign) NSString * VCtype  ;//18 导学


@end



@interface playVideoModel : NSObject

@property(nonatomic,copy) NSString *videoUrl;

@property(nonatomic,assign)float duration; //时长

@property(nonatomic,assign)float videoDuration; //视频处于总视频的时长位置

@end
