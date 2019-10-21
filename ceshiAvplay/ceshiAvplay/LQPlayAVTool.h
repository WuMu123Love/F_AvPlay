//
//  LQPlayAVTool.h
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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,LQAVPlayType){
    LQAVPlayTypeVideo,
    LQAVPlayTypeAudio
};


@interface LQPlayAVTool : NSObject


/**
 播放入口方法
 
 @param vuid 乐视的vuid
 @param url url播放    注意:(vuid和url只能传入一个值，另一个值为nil)
 @param type 音频播放还是视频播放
 @param title 标题
 @param popTitles 弹出框文字数组
 detailType 根据传输数据判断界面布局  18：导学详情➕分享按钮
 @param action 弹出框点击事件回调
 ShareBlock 分享回调
 */
+ (void)lc_playAVWithVuid:(NSString *)vuid  url:(NSURL *)url type:(LQAVPlayType)type  title:(NSString *)title popTitles:(NSArray *)popTitles videoInfos:(NSArray *)videoInfos detailType:(NSString *)detailType actonBlock:(void (^)(NSInteger index))action ShareBlock:(void(^)(void))shareBlock;
/**
 播放入口方法

 @param vuid 乐视的vuid
 @param url url播放    注意:(vuid和url只能传入一个值，另一个值为nil)
 @param type 音频播放还是视频播放
 @param title 标题
 @param popTitles 弹出框文字数组
 @param action 弹出框点击事件回调
 */
+ (void)lc_playAVWithVuid:(NSString *)vuid  url:(NSURL *)url type:(LQAVPlayType)type  title:(NSString *)title popTitles:(NSArray *)popTitles videoInfos:(NSArray *)videoInfos actonBlock:(void (^)(NSInteger index))action;


/**
 播放入口(表演课堂限制播放时间)
 */
+ (void)lc_playAVWithVuid:(NSString *)vuid  url:(NSURL *)url type:(LQAVPlayType)type  title:(NSString *)title  popTitles:(NSArray *)popTitles actonBlock:(void (^)(NSInteger index))action isNoOpen:(BOOL)isNoOpen;

@end
