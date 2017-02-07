//
//  MPMPlayerViewController.m
//  TestMPMPlayer
//
//  Created by picomax on 2016. 6. 15..
//  Copyright © 2016년 picomax. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "MPMPlayerViewController.h"

#define degreeToRadian(x) (M_PI * x / 180.0)
#define radianToDegree(x) (180.0 * x / M_PI)

@interface MPMPlayerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (strong, nonatomic) MPMoviePlayerController *player;
@property (assign, nonatomic) CGFloat degree;
@end

@implementation MPMPlayerViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //NSString *urlString = @"http://farm32.ids.skplanet.com:8012/hub/candy/media/1001000/1001000012/1001000012.mp4";
    //NSURL *url = [NSURL URLWithString:urlString];
    //[self setVideoWithFrame:CGRectMake(0, 0, 320, 480) videoUrl:url];
}

- (void)setVideoWithFrame:(CGRect)frame videoUrl:(NSURL*)url degree:(CGFloat)degree {
    self.degree = degree;
    
    self.player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    //[_player prepareToPlay];
    [_player.view setFrame:frame];
    [_player setControlStyle:MPMovieControlStyleNone];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:_player];
    //[_player play];
}

- (void)playVideo {
    [_player play];
}

-(void)movieLoadStateDidChange:(NSNotification*)notification {
    if (_player.loadState) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:_player];
        
        // 이 지점에서 사이즈를 읽어서..
        NSLog(@"%f, %f", _player.naturalSize.width, _player.naturalSize.height);
        _sizeLabel.text = [NSString stringWithFormat:@"동영상 실제 크기는 %.1f x %.1f", _player.naturalSize.width, _player.naturalSize.height];
        
        // 여기서 회전시키면 됨..
        _player.view.transform = CGAffineTransformMakeRotation(degreeToRadian(_degree));
        
        [self.view addSubview:_player.view];
    }
}

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
