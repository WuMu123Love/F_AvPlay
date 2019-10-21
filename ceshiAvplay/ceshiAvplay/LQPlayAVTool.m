//
//  LQPlayAVTool.m
//  PlayVideoDemo
//
// ********************************************
// *          _____             _____         *
// *          \   /             \   /         *
// *          /  /              /  /          *
// *         /  /              /  /           *
// *        /  /__            /  /__          *
// *       /_____/           /_____/          *
// *                                          *
// ********************************************
//
//  Created by 李磊 on 2017/5/2.
//  Copyright © 2017年 李磊www. All rights reserved.
//

#import "LQPlayAVTool.h"
//#import "LQLCVodViewController.h"
//#import "LQAppUtil.h"
#import "LQPlayVideoViewController.h"

@interface LQPlayAVTool()

@end

@implementation LQPlayAVTool

+ (void)lc_playAVWithVuid:(NSString *)vuid  url:(NSURL *)url type:(LQAVPlayType)type  title:(NSString *)title popTitles:(NSArray *)popTitles videoInfos:(NSArray *)videoInfos detailType:(NSString *)detailType actonBlock:(void (^)(NSInteger index))action ShareBlock:(void(^)(void))shareBlock{
    
    if (!videoInfos) {
        NSAssert(url || vuid, @"vuid和url都为空");
        NSAssert(!(url && vuid) , @"只能指定一种播放方式");
    }
    if (vuid.length>0) {
//        LQLCVodViewController * nextVc = [[LQLCVodViewController alloc] init];
//        nextVc.uu = @"b68e945493";
//        nextVc.vu = vuid;
//        nextVc.popTitles = popTitles;
//        nextVc.selectedBlock = action;
//        nextVc.sourceUrl = url;
//        nextVc.title = title;
//        nextVc.type = type;
//        nextVc.VCtype = detailType;
//        nextVc.ClickShareBlock = shareBlock;
//
//        [[LQAppUtil appTopViewController] presentViewController:nextVc animated:YES completion:nil];
        
    }else if(videoInfos.count > 0){
        NSMutableArray *dataArr = [NSMutableArray array];
        CGFloat time = 0;
        for (NSDictionary *infoDic in videoInfos) {
            playVideoModel *model = [[playVideoModel alloc]init];
            model.duration        = [infoDic[@"duration"] floatValue];
            model.videoUrl        = [infoDic[@"videoUrl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
            model.videoDuration   = time + model.duration;
            [dataArr addObject:model];
            time = model.videoDuration;
        }
        LQPlayVideoViewController *nextVc = [[LQPlayVideoViewController alloc] initWithVideoModels:[dataArr copy] type:type];
        nextVc.popTitles = popTitles;
        nextVc.selectedBlock = action;
        nextVc.title = title;
//        [[LQAppUtil appTopViewController] presentViewController:nextVc animated:YES completion:nil];
    }else{
        LQPlayVideoViewController *nextVc = [[LQPlayVideoViewController alloc] initWithVideoUrl:url type:type];
        nextVc.popTitles = popTitles;
        nextVc.selectedBlock = action;
        nextVc.title = title;
        nextVc.VCtype = detailType;
        nextVc.ClickShareBlock = shareBlock;
//        [[LQAppUtil appTopViewController] presentViewController:nextVc animated:YES completion:nil];
    }
}


+ (void)lc_playAVWithVuid:(NSString *)vuid  url:(NSURL *)url type:(LQAVPlayType)type  title:(NSString *)title popTitles:(NSArray *)popTitles videoInfos:(NSArray *)videoInfos actonBlock:(void (^)(NSInteger index))action{

    if (!videoInfos) {
        NSAssert(url || vuid, @"vuid和url都为空");
        NSAssert(!(url && vuid) , @"只能指定一种播放方式");
    }
    if (vuid.length>0) {
//        LQLCVodViewController * nextVc = [[LQLCVodViewController alloc] init];
//        nextVc.uu = @"b68e945493";
//        nextVc.vu = vuid;
//        nextVc.popTitles = popTitles;
//        nextVc.selectedBlock = action;
//        nextVc.sourceUrl = url;
//        nextVc.title = title;
//        nextVc.type = type;
//
//        [[LQAppUtil appTopViewController] presentViewController:nextVc animated:YES completion:nil];
        
    }else if(videoInfos.count > 0){
        NSMutableArray *dataArr = [NSMutableArray array];
        CGFloat time = 0;
        for (NSDictionary *infoDic in videoInfos) {
            playVideoModel *model = [[playVideoModel alloc]init];
            model.duration        = [infoDic[@"duration"] floatValue];
            model.videoUrl        = [infoDic[@"videoUrl"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];;
            model.videoDuration   = time + model.duration;
            [dataArr addObject:model];
            time = model.videoDuration;
        }
        LQPlayVideoViewController *nextVc = [[LQPlayVideoViewController alloc] initWithVideoModels:[dataArr copy] type:type];
        nextVc.popTitles = popTitles;
        nextVc.selectedBlock = action;
        nextVc.title = title;
//        [[LQAppUtil appTopViewController] presentViewController:nextVc animated:YES completion:nil];
    }else{
        LQPlayVideoViewController *nextVc = [[LQPlayVideoViewController alloc] initWithVideoUrl:url type:type];
        nextVc.popTitles = popTitles;
        nextVc.selectedBlock = action;
        nextVc.title = title;
        nextVc.VCtype = @"18";
        nextVc.ClickShareBlock = ^{
        //点分享按钮
        };
//        [[LQAppUtil appTopViewController] presentViewController:nextVc animated:YES completion:nil];
    }
}

/**
 播放入口(表演课堂限制播放时间)
 */
+ (void)lc_playAVWithVuid:(NSString *)vuid  url:(NSURL *)url type:(LQAVPlayType)type  title:(NSString *)title  popTitles:(NSArray *)popTitles actonBlock:(void (^)(NSInteger index))action isNoOpen:(BOOL)isNoOpen
{
    NSAssert(url || vuid, @"vuid和url都为空");
    NSAssert(!(url && vuid) , @"只能指定一种播放方式");
    
    if (vuid.length>0) {
        
//        LQLCVodViewController * nextVc = [[LQLCVodViewController alloc] init];
//        nextVc.uu = @"b68e945493";
//        nextVc.vu = vuid;
//        nextVc.popTitles = popTitles;
//        nextVc.selectedBlock = action;
//        nextVc.sourceUrl = url;
//        nextVc.title = title;
//        nextVc.type = type;
//        nextVc.isNoOpen = isNoOpen;
//        [[LQAppUtil appTopViewController] presentViewController:nextVc animated:YES completion:nil];
        
    }else{
        
        LQPlayVideoViewController *nextVc = [[LQPlayVideoViewController alloc] initWithVideoUrl:url type:type];
        nextVc.popTitles = popTitles;
        nextVc.selectedBlock = action;
        nextVc.title = title;
        nextVc.isNoOpen = isNoOpen;
//        [[LQAppUtil appTopViewController] presentViewController:nextVc animated:YES completion:nil];
    }
}

@end
