//
//  AVPlayerViewController.h
//  TestAVPlayer
//
//  Created by picomax on 2016. 6. 15..
//  Copyright © 2016년 picomax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AVPlayerViewController : UIViewController
- (void)setVideoWithFrame:(CGRect)frame videoUrl:(NSURL*)url degree:(CGFloat)degree;
- (void)playVideo;
@end
