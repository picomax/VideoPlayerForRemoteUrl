//
//  ViewController.m
//  TestMPMPlayer
//
//  Created by picomax on 2016. 6. 15..
//  Copyright © 2016년 picomax. All rights reserved.
//

#import "AVPlayerViewController.h"
#import "ViewController.h"

//NSString *const DefaultVideoUrl = @"http://farm32.ids.skplanet.com:8012/hub/candy/media/1001000/1001000012/1001000012.mp4";
NSString *const DefaultVideoUrl = @"http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8";

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UITextField *degreeTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_urlTextField addTarget:self
                        action:@selector(dismissKeyboard:)
              forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [_degreeTextField addTarget:self
                      action:@selector(dismissKeyboard:)
            forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (IBAction)submitButtonTapped:(id)sender {
    NSString *urlString = _urlTextField.text;
    NSString *degreeString = _degreeTextField.text;
    
    if(urlString == nil || [urlString length] == 0){
        urlString = DefaultVideoUrl;
    }
    
    if([urlString hasPrefix:@"http"] == NO){
        urlString = [NSString stringWithFormat:@"http://%@", urlString];
    }
    
    if(degreeString == nil || [degreeString length] == 0){
        degreeString = @"0";
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    CGFloat degree = [degreeString floatValue];
    
    if(url == nil || [url.absoluteString isEqualToString:@"http://"] == YES){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"URL Error!"
                                                       message:@"Please check the URL you entered." delegate:self
                                             cancelButtonTitle:@"Confirm"
                                             otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] initWithNibName:NSStringFromClass([AVPlayerViewController class]) bundle:nil];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    [playerViewController setVideoWithFrame:CGRectMake(20, 90, frame.size.width-40, frame.size.height-180) videoUrl:url degree:degree];
    
    [self presentViewController:playerViewController animated:YES completion:^{
        [playerViewController playVideo];
    }];
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}

@end
