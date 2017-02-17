//
//  AVPlayerViewController.m
//  TestAVPlayer
//
//  Created by picomax on 2016. 6. 15..
//  Copyright © 2016년 picomax. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AVPlayerViewController.h"

#define contains(str1, str2) ([str1 rangeOfString: str2 ].location != NSNotFound)


//NSString *const AVPlayerStartMediaNotificationKey = @"AVPlayerStartMediaNotificationKey";

#define degreeToRadian(x) (M_PI * x / 180.0)
#define radianToDegree(x) (180.0 * x / M_PI)

@interface AVPlayerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (nonatomic, strong) UIView * videoView;
@property (nonatomic, strong) AVPlayerLayer* playerLayer;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (assign, nonatomic) CGFloat degree;
@property (strong, nonatomic) AVPlayerItemVideoOutput *videoOutput;
@property (assign, nonatomic) NSInteger videoWidth;
@property (assign, nonatomic) NSInteger videoHeight;
//@property (strong, nonatomic) AVAssetImageGenerator *imageGenerator;
@end

@implementation AVPlayerViewController

- (void)dealloc {
    @try {
        [_player removeObserver:self forKeyPath:@"status"];
    } @catch (NSException *exception) {
        //<#Handle an exception thrown in the @try block#>
    } @finally {
        //<#Code that gets executed whether or not an exception is thrown#>
    }
    
    @try {
        [_player removeObserver:self forKeyPath:@"rate"];
    } @catch (NSException *exception) {
        //<#Handle an exception thrown in the @try block#>
    } @finally {
        //<#Code that gets executed whether or not an exception is thrown#>
    }
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    } @catch (NSException *exception) {
        //<#Handle an exception thrown in the @try block#>
    } @finally {
        //<#Code that gets executed whether or not an exception is thrown#>
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setVideoWithFrame:(CGRect)frame videoUrl:(NSURL*)url degree:(CGFloat)degree {
    self.degree = degree;
    
    self.videoView = [[UIView alloc] initWithFrame:frame];
    //_player = [AVPlayer playerWithURL:url];
    _player.volume = 0.0f;
    
    //if( contains(url.absoluteString, @".m3u") == YES )
    //{
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
        self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    //}
    //else
    //{
    //    _player = [AVPlayer playerWithURL:url];
    //}
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    _playerLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    //playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    _playerLayer.needsDisplayOnBoundsChange = YES;
    
    [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    [_player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    NSString* const key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* const value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* const settings = @{ key : value };
    self.videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:settings];
    [_player.currentItem addOutput:_videoOutput];
    
    [_videoView.layer addSublayer:_playerLayer];
    _videoView.layer.needsDisplayOnBoundsChange = YES;
    
    [self.view addSubview:_videoView];
}

- (void)playVideo {
    [_player play];
}

- (void)stopVideo {
    [_player seekToTime:CMTimeMake(0, 1)];
    [_player pause];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    __weak __typeof__(self) weakSelf = self;
    
    //To print out if it is 'rate' or 'status' that has changed:
    NSLog(@"Changed: %@", keyPath);
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       if ([keyPath isEqualToString:@"rate"]) //If rate has changed:
                       {
                           if ([weakSelf.player rate] != 0) //If it started playing
                           {
                               // This NSLog is supposed to print out the duration of the video.
                               NSLog(@"Total time: %f", CMTimeGetSeconds([[weakSelf.player currentItem] duration]));
                               
                               [weakSelf rotateVideoPlayer];
                               
                               //[weakSelf updateResolutionWithDelay:0.5];
                               [weakSelf updateResolution];
                           }
                       }
                       else if ([keyPath isEqualToString:@"status"]) // If the status changed
                       {
                           if(weakSelf.player.status == AVPlayerStatusReadyToPlay) //If "ReadyToPlay"
                           {
                               NSLog(@"ReadyToPlay");
                               [weakSelf.player play]; //Start the video
                           }
                       }
                   });
}

- (void)updateResolutionWithDelay:(CGFloat)delay {
    __weak __typeof__(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ((weakSelf.player.rate != 0) && (weakSelf.player.error == nil))
        {
            [weakSelf updateResolution];
        }
    });
}

- (void)updateResolution {
    /*
    //for Local Asset^^
    AVAsset *asset = _player.currentItem.asset;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:_player.currentItem.currentTime actualTime:nil error:nil];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    NSLog(@"Size : %f, %f", image.size.width, image.size.height);
    // CGImageRef won't be released by ARC
    CGImageRelease(imageRef);
    */
    
    // player is playing
    if ((_player.rate != 0) && (_player.error == nil))
    {
        AVAssetTrack *track = [[_player.currentItem.asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        if (track != nil)
        {
            CGSize naturalSize = [track naturalSize];
            naturalSize = CGSizeApplyAffineTransform(naturalSize, track.preferredTransform);
            _videoWidth = (NSInteger) naturalSize.width;
            _videoHeight = (NSInteger) naturalSize.height;
        }
        else
        {
            CMTime currentTime = _player.currentItem.currentTime;
            CVPixelBufferRef buffer = [_videoOutput copyPixelBufferForItemTime:currentTime itemTimeForDisplay:nil];
            //CIImage *ciImage = [CIImage imageWithCVPixelBuffer:buffer];
            //UIImage *image = [UIImage imageWithCIImage:ciImage];
            //You can use the image^^;
            _videoWidth = CVPixelBufferGetWidth(buffer);
            _videoHeight = CVPixelBufferGetHeight(buffer);
        }
    }
    _sizeLabel.text = [NSString stringWithFormat:@"Resolution : %ld x %ld", _videoWidth, _videoHeight];
    
    if(_videoWidth <= 0 && _videoHeight <= 0){
        [self updateResolutionWithDelay:0.5];
    }
    //[self rotateVideoPlayer];
}

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rotateVideoPlayer {
    [_playerLayer setAffineTransform:CGAffineTransformMakeRotation(degreeToRadian(_degree))];
}

@end
