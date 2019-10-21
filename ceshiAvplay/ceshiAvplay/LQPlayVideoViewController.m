//
//  LQPlayVideoViewController.m
//  PlayVideoDemo
//
//  Created by 李磊 on 2017/4/27.
//  Copyright © 2017年 李磊www. All rights reserved.
//

#import "LQPlayVideoViewController.h"
#import "Masonry.h"
#import "LQPopoverView.h"

#define kHideTime  4  //隐藏工具条的时间

@import AVFoundation;

@interface LQPlayVideoViewController ()

@property (strong, nonatomic) AVPlayer *avPlayer;
@property (strong, nonatomic) AVPlayerLayer *avPlayerLayer;
@property(nonatomic,strong) AVPlayerItem *playerItem;

@property(nonatomic,strong) UIButton *playBtn;//底部播放按钮
@property(nonatomic,strong) UIButton *middlePlayBtn;//居中的播放按钮


@property(nonatomic,strong) UIView *bottomView;
@property(nonatomic,strong) UIView *headerView;

@property(nonatomic,strong) UILabel *currentTimeLb;
@property(nonatomic,strong) UILabel *totalTimeLb;


@property(nonatomic,strong) UISlider *slider;
@property(nonatomic,strong) id timeObserver;


@property(nonatomic,strong)  UITapGestureRecognizer *tapGes;//点按手势

@property(nonatomic,strong) UIImageView *audioIv;

@property(nonatomic,assign) LQAVPlayType type;

@property (strong, nonatomic) UIActivityIndicatorView *loadIndicatorView;//菊花

@property(nonatomic,assign) BOOL isLocal;//是否是本地

@property(nonatomic,strong)NSArray *videoModels;

@property(nonatomic,assign)NSInteger playVideoIndex;

@property(nonatomic,assign)CGFloat playVideoTime;
@end

@implementation LQPlayVideoViewController

#pragma mark - set/get

// AVPlayer
-(AVPlayer *)avPlayer{
    if (!_avPlayer) {
        
        _avPlayer =[AVPlayer playerWithPlayerItem:self.playerItem];;
        _avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        _avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[_avPlayer currentItem]];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        self.avPlayerLayer.frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
        
        [self.view.layer addSublayer:self.avPlayerLayer];
        
        //监控时间进度
        __weak typeof(self) weakSelf = self;
        self.timeObserver = [_avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 5) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            NSInteger currentTime =  (NSInteger)CMTimeGetSeconds(time);
            weakSelf.currentTimeLb.text = [weakSelf timeFormatted:currentTime];
            weakSelf.slider.value = CMTimeGetSeconds(time);
            NSLog(@"%ld",(long)currentTime);
        }];
    }
    return _avPlayer;
}

//  底部工具条
-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [UIView new];
        [self.view addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.height.equalTo(@60);
        }];
        _bottomView.backgroundColor = [UIColor clearColor];
        _bottomView.alpha = 0;
        
        
        UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bottomView addSubview:playBtn];
        [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_bottomView);
            make.left.equalTo(@20);
            make.height.width.equalTo(@40);
        }];
        self.playBtn = playBtn;
//        [playBtn setImage:BSBundleImageNamed(@"lq_pause") forState:UIControlStateNormal];
//        [playBtn setImage:BSBundleImageNamed(@"lq_play") forState:UIControlStateSelected];
        [playBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
        
        self.currentTimeLb = [UILabel new];
        [_bottomView addSubview:self.currentTimeLb];
        self.currentTimeLb.font = [UIFont systemFontOfSize:12];
        self.currentTimeLb.textColor = [UIColor whiteColor];
        self.currentTimeLb.text = @"00:00";
        [self.currentTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(playBtn.mas_right).offset(8);
            make.centerY.equalTo(_bottomView);
        }];
        
        CGFloat totals = 0;
        for (playVideoModel *model in self.videoModels) {
            totals = totals + model.duration;
        }
        
        self.totalTimeLb = [UILabel new];
        [_bottomView addSubview:self.totalTimeLb];
        self.totalTimeLb.font = [UIFont systemFontOfSize:12];
        self.totalTimeLb.textColor = [UIColor whiteColor];
        self.totalTimeLb.text = [self timeFormatted:self.videoModels.count > 1?(NSInteger)totals:(NSInteger)CMTimeGetSeconds(self.playerItem.asset.duration)];
        [self.totalTimeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-30));
            make.centerY.equalTo(_bottomView);
        }];
        
        self.slider = [[UISlider alloc] initWithFrame:CGRectZero];
        [_bottomView addSubview:self.slider];
//        [self.slider setThumbImage:BSBundleImageNamed(@"lq_movepoint") forState:UIControlStateNormal];
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.currentTimeLb.mas_right).offset(10);
            make.right.equalTo(self.totalTimeLb.mas_left).offset(-10);
            make.centerY.equalTo(_bottomView);
        }];
        self.slider.tintColor = [UIColor whiteColor];
        self.slider.maximumValue = self.videoModels.count > 1?(NSInteger)totals:CMTimeGetSeconds(self.playerItem.asset.duration);
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.slider addTarget:self action:@selector(sliderBegan:) forControlEvents:UIControlEventTouchDown];
        [self.slider addTarget:self action:@selector(sliderEnd:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _bottomView;
}

// 头部工具条
- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [UIView new];
        
        [self.view addSubview:_headerView];
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.view);
            make.height.equalTo(@64);
        }];
        _headerView.backgroundColor = [UIColor clearColor];
        _headerView.alpha = 0;
        _headerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_headerView addSubview:cancelBtn];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_headerView).offset(10);
            make.left.equalTo(_headerView);
            make.height.equalTo(@40);
            make.width.equalTo(@60);
        }];
        [cancelBtn setImage:[UIImage imageNamed:@"nav_backarrow_white_ico"] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *titleLb = [UILabel new];
        [_headerView addSubview:titleLb];
        [titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(cancelBtn);
            make.centerX.equalTo(_headerView);
            make.left.mas_greaterThanOrEqualTo(60);
            make.right.mas_greaterThanOrEqualTo(-60);
        }];
        titleLb.font = [UIFont systemFontOfSize:18];
        titleLb.textColor = [UIColor whiteColor];
        titleLb.text = self.title;
        titleLb.textAlignment = NSTextAlignmentCenter;
        
        
        if (self.popTitles.count>0) {
            
            UIButton *popBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_headerView addSubview:popBtn];
            [popBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_headerView).offset(10);
                make.right.equalTo(_headerView).offset(-20);
                make.height.mas_equalTo(40);
            }];
//            [popBtn setImage:BSBundleImageNamed(@"lq_more@2x") forState:UIControlStateNormal];
            [popBtn addTarget:self action:@selector(showPopView:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        if ([self.VCtype isEqualToString:@"18"]) {
            //适配导学作业
            UIView * rightBGView = [[UIView alloc] initWithFrame:CGRectZero];
            UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
//            [btn setImage:BSBundleImageNamed(@"Share_All") forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(clickshareButton) forControlEvents:UIControlEventTouchUpInside];
            [rightBGView addSubview:btn];
            [_headerView addSubview:rightBGView];
            [rightBGView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_headerView.mas_right).offset(-15);
                make.bottom.equalTo(_headerView.mas_bottom).offset(-10);
                make.width.height.mas_equalTo(25);
            }];
        }

    }
    return _headerView;
}

//点击分享按钮
- (void)clickshareButton{
    if (self.ClickShareBlock) {
        self.ClickShareBlock();
    }
    
    
}

- (UIButton *)middlePlayBtn{
    if (!_middlePlayBtn) {
        _middlePlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _middlePlayBtn.backgroundColor = [UIColor redColor];
        [self.view addSubview:_middlePlayBtn];
        [_middlePlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
//        [_middlePlayBtn setImage:BSBundleImageNamed(@"lq_playIcon") forState:UIControlStateNormal];
        [_middlePlayBtn addTarget:self action:@selector(middleBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _middlePlayBtn;
}

-(UIImageView *)audioIv{
    if (!_audioIv) {
        _audioIv = [UIImageView new];
        [self.view addSubview:_audioIv];
        _audioIv.contentMode = UIViewContentModeScaleAspectFit;
        [_audioIv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
//        _audioIv.image =  BSBundleImageNamed(@"lq_audioImage");
        
    }
    return _audioIv;
}

- (UIActivityIndicatorView *)loadIndicatorView{
    if (!_loadIndicatorView) {
        _loadIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _loadIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [_loadIndicatorView startAnimating];
        [self.view addSubview:_loadIndicatorView];
        [_loadIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
        }];
        _loadIndicatorView.hidesWhenStopped = YES;
    }
    return _loadIndicatorView;
}


#pragma mark - lifeCycle

- (instancetype)initWithVideoUrl:(NSURL *)url type:(LQAVPlayType)type{
    self = [super init];
    if(self) {
        _playerItem = [AVPlayerItem playerItemWithURL:url];
        if ([url.scheme isEqualToString:@"file"]) {//本地
            self.isLocal = YES;
        }else{
            [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:0 context:nil];
            [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:0 context:nil];
        
        }
        _type = type;
    }
    
    return self;
}

-(instancetype)initWithVideoModels:(NSArray *)videoModels type:(LQAVPlayType)type{
    self = [super init];
    if(self) {
        playVideoModel *model = [videoModels firstObject];
        _playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:model.videoUrl]];
        [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:0 context:nil];
        [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:0 context:nil];
        _type = type;
        self.videoModels = videoModels;
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[AVPlayerItem class]])
    {
        AVPlayerItem *item = (AVPlayerItem *)object;
        //playerItem status value changed?
       if ([keyPath isEqualToString:@"playbackBufferEmpty"])
        {
            
            
            if (item.playbackBufferEmpty)
            {
                [self.loadIndicatorView startAnimating];
                
            }
        }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
            
            if (item.playbackLikelyToKeepUp)
                
            {
                [self.loadIndicatorView stopAnimating];
                
            }
        }
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor colorWithRed:(48.0/255) green:(47.0/255) blue:(47.0/255) alpha:1];
    
    [self avPlayer];
    
    //点按手势
    self.tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideToolView:)];
    [self.view addGestureRecognizer:self.tapGes];

    // 默认执行一次，这样4秒后才能隐藏工具view
    [self showOrHideToolView:self.tapGes];
    
    if (self.type == LQAVPlayTypeAudio) {//音频
        [self audioIv];
    }
    
    if (!self.isLocal) {//不是本地
        
        [self loadIndicatorView];
    }
    //监听耳机的插拔
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
    if (_isNoOpen) {
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC);
        dispatch_after(delayTime, dispatch_get_main_queue(), ^(void){
            //暂停视频音频
            [self.avPlayer pause];
            self.middlePlayBtn.hidden = NO;
            //创建一个弹框
            UIAlertController *addAlertVC = [UIAlertController alertControllerWithTitle:@"继续观看，请先加入学校。" message:nil preferredStyle:UIAlertControllerStyleAlert];
            //创建 确认按钮(事件) 并添加到弹窗界面
            UIAlertAction *confirmAction =[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
                [self cancelButtonPressed:nil];
            }];
            [addAlertVC addAction:confirmAction];
            [self presentViewController:addAlertVC animated:YES completion:nil];
        });
    }
}

//相应的事件
- (void)routeChange:(NSNotification *)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger roteChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (roteChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            //插入耳机
            NSLog(@"插入耳机");
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            //拔出耳机
            NSLog(@"拔出耳机");
            [self playOrPause:self.playBtn];
            break;
            
    }
    
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.avPlayer play];
}

-(void)dealloc{
    
    // 移除时间观察者
    [self.avPlayer removeTimeObserver:self.timeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (!self.isLocal) {
        [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];

    }
    
    self.avPlayer = nil;
    self.playerItem = nil;
}

#pragma mark - Action

/**
 slider被点击时调用
 */
- (void)sliderBegan:(UISlider *)slider{
    //开始滑动时禁用手势响应   (不禁用会有冲突)
    self.tapGes.enabled = NO;
    if (!self.playBtn.selected) {
         [self playOrPause:self.playBtn];
    }
   
    //滑动事取消隐藏时间
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolView) object:nil];
    
}

/**
 slider松开时调用
 */
- (void)sliderEnd:(UISlider *)slider{
    //结束滑动时开启手势响应
    self.tapGes.enabled = YES;
    // 滑动结束后 重新计时
    [self performSelector:@selector(hideToolView) withObject:nil afterDelay:4];
    
    if (self.videoModels.count > 1) {
        CGFloat  totalTimeT = 0;
        for (int i = 0; i < self.videoModels.count; i++) {
            playVideoModel *model = self.videoModels [i];
            totalTimeT = totalTimeT + model.duration;
            if (totalTimeT > slider.value) {
                self.playVideoIndex = i;
                totalTimeT = totalTimeT - model.duration;
                break;
            }
        }
        [self resetAvPlayer];
        [self.avPlayer play];
        __weak typeof(self) weakSelf = self;
        [self.avPlayer seekToTime:CMTimeMakeWithSeconds(self.slider.value - totalTimeT, 30) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            [self playOrPause:self.playBtn];
            if (!weakSelf.isLocal) {
                if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp) {
                    [self.loadIndicatorView startAnimating];
                }
            }
        }];
    }else{
          [self playOrPause:self.playBtn];
    }
    
}
/**
 slider滑动时低啊用
 */
-(void)sliderValueChanged:(UISlider *)slider{
    NSLog(@"%f",slider.value);
    if (!self.videoModels || self.videoModels.count == 1) {
        __weak typeof(self) weakSelf = self;
        [self.avPlayer seekToTime:CMTimeMakeWithSeconds(self.slider.value, 30) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (!weakSelf.isLocal) {
                if (!weakSelf.playerItem.isPlaybackLikelyToKeepUp) {
                    [self.loadIndicatorView startAnimating];
                }
            }
        }];
    }else{
        self.currentTimeLb.text = [self timeFormatted:slider.value];
    }

}


/**
 暂停/播放事件
 */
- (void)playOrPause:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {//暂停
        [self.avPlayer pause];
        self.middlePlayBtn.hidden = NO;
    }else{//播放
        [self.avPlayer play];
        self.middlePlayBtn.hidden = YES;
    }
}


/**
    中间的播放按钮的点击事件
 */
- (void)middleBtnClicked{
    [self playOrPause:self.playBtn];
}




/**
 点按手势
 
 */
- (void)showOrHideToolView:(UITapGestureRecognizer *)tapGes{
    // 取消延时调用的方法，否则会多次调用
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolView) object:nil];
    if (self.bottomView.alpha>0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.bottomView.alpha = 0;
            self.headerView.alpha = 0;
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }];
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            self.bottomView.alpha = 1;
            self.headerView.alpha = 1;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        } completion:^(BOOL finished) {
            [self performSelector:@selector(hideToolView) withObject:nil afterDelay:kHideTime];
        }];
        
    }
}

// 写成方法  用于performSelector调用  和 cancelPreviousPerformRequestsWithTarget取消
- (void)hideToolView{
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.alpha = 0;
        self.headerView.alpha = 0;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }];
}

/**
 播放完成的通知(用于重复播放)
 */
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    if (self.videoModels.count > 1) {
        if (self.playVideoIndex + 1 <  self.videoModels.count) {
            self.playVideoIndex ++;
            [self resetAvPlayer];
            [self.avPlayer play];
        }else{
            // 播放完成后  暂停播放，进度移动到最开始位置
            self.playVideoIndex = 0;
            [self playOrPause:self.playBtn];
            AVPlayerItem *p = [notification object];
            [p seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
               [self resetAvPlayer];
            }];
        }
    }else{
        // 播放完成后  暂停播放，进度移动到最开始位置
        self.playVideoIndex = 0;
        [self playOrPause:self.playBtn];
        
        AVPlayerItem *p = [notification object];
        [p seekToTime:kCMTimeZero];
    }
}

/**
 返回事件
 */
- (void)cancelButtonPressed:(UIButton *)button {
    // 弹出框弹出时取消隐藏事件
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolView) object:nil];
     [self.avPlayer pause];
    [self dismissViewControllerAnimated:YES completion:nil];
}



/**
 弹出框
 */
- (void)showPopView:(UIButton *)btn{
    
    // 弹出框弹出时取消隐藏事件
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToolView) object:nil];
    CGRect rc = [btn.superview convertRect:btn.frame toView:self.view];
    CGPoint point = CGPointMake(rc.origin.x + rc.size.width/2, 64);
    LQPopoverView *pop = [[LQPopoverView alloc] initWithPoint:point titles:self.popTitles images:nil];
    
    __weak typeof(self) weakSelf = self;
    //选择的block
    pop.selectRowAtIndex = ^(NSInteger index){
        if (weakSelf.selectedBlock) {
            weakSelf.selectedBlock(index);
        }
    };
    pop.dismissBlock = ^{
        [weakSelf performSelector:@selector(hideToolView) withObject:nil afterDelay:4];
    };
    [pop show];
}



#pragma mark - system

// 屏幕旋转代理
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    NSLog(@"%@",NSStringFromCGSize(size));
    if(size.width < size.height){
        self.avPlayerLayer.frame = CGRectMake(0, 0, size.width, size.height);
    }else{
        self.avPlayerLayer.frame = CGRectMake(0, 64, size.width, size.height - 64 - 64);
    }

}

- (BOOL)shouldAutorotate
{
    return self.videoModels.count > 0 ? YES : NO;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

#pragma mark-  时间转换
- (NSString *)timeFormatted:(NSInteger)totalSeconds
{
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02li:%02li", minutes, seconds];
}


-(void)resetAvPlayer{
    playVideoModel *videoModel = self.videoModels[self.playVideoIndex];
    _playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:videoModel.videoUrl]];
    // 移除时间观察者
    [self.avPlayer removeTimeObserver:self.timeObserver];
    [self.avPlayer replaceCurrentItemWithPlayerItem:_playerItem];
    
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [_avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 5) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        playVideoModel *model;
        if(self.playVideoIndex != 0) model = self.videoModels [self.playVideoIndex - 1];
        NSInteger currentTime =  (NSInteger)CMTimeGetSeconds(time);
        if (model) currentTime = model.videoDuration + currentTime;
        weakSelf.currentTimeLb.text = [weakSelf timeFormatted:currentTime];
        weakSelf.slider.value = model? model.videoDuration + CMTimeGetSeconds(time):CMTimeGetSeconds(time);
        NSLog(@"%ld",(long)currentTime);
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[_avPlayer currentItem]];
}


@end

@implementation playVideoModel

@end
