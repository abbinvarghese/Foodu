//
//  FFirstLaunchViewController.m
//  Foodu
//
//  Created by Abbin on 15/03/16.
//  Copyright © 2016 Paadam. All rights reserved.
//

#import "FFirstLaunchViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "FPageTHREEViewController.h"
#import "FSignUpOneViewController.h"

@interface FFirstLaunchViewController ()

@property (nonatomic, strong) AVPlayer *avplayer;

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIView *gradientView;

@property (strong, nonatomic) UIPageViewController *pageViewController;

@end

@implementation FFirstLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initVideoBackground];
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FirstLaunch" bundle:nil];
    FPageONEViewController*rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"FPageONEViewController"];
    rootViewController.delegate = self;
    [self.pageViewController setViewControllers:@[rootViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = self.view.frame;
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)initVideoBackground{
    
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
    [[AVAudioSession sharedInstance] setActive:YES error:&sessionError];
    
    //Set up player
    NSURL *movieURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"IMG_0101" ofType:@"mp4"]];
    AVAsset *avAsset = [AVAsset assetWithURL:movieURL];
    AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
    self.avplayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
    AVPlayerLayer *avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:self.avplayer];
    [avPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [avPlayerLayer setFrame:[[UIScreen mainScreen] bounds]];
    [self.playerView.layer addSublayer:avPlayerLayer];
    //Config player
    [self.avplayer seekToTime:kCMTimeZero];
    [self.avplayer setVolume:0.0f];
    [self.avplayer setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avplayer currentItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerStartPlaying)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = [[UIScreen mainScreen] bounds];
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0 alpha:0.2].CGColor,(id)[UIColor colorWithWhite:0 alpha:1].CGColor,nil];
    [self.gradientView.layer insertSublayer:gradient atIndex:0];
}

- (void)playerStartPlaying{
    
    [self.avplayer play];
    
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    
}

-(void)ONEClickedNext:(FPageONEViewController *)viewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FirstLaunch" bundle:nil];
    FPageTWOViewController*rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"FPageTWOViewController"];
    rootViewController.delegateObj = self;
    [self.pageViewController setViewControllers:@[rootViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

-(void)TWOClickedNext:(FPageFour *)viewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FirstLaunch" bundle:nil];
    FPageTHREEViewController*rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"FPageTHREEViewController"];
    rootViewController.delegate = self;
    [self.pageViewController setViewControllers:@[rootViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

-(void)THREEClickedNext:(FPageTHREEViewController *)viewController withLocation:(NSMutableDictionary *)location{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FirstLaunch" bundle:nil];
    FPageFOURViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"FPageFOURViewController"];
    rootViewController.delegate = self;
    rootViewController.location = location;
    [self.pageViewController setViewControllers:@[rootViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

-(void)FPageFOURSwitchToEmailSignUp:(FPageFOURViewController *)controller withLocation:(NSMutableDictionary *)location{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FirstLaunch" bundle:nil];
    FEmailSignUpNAMEViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"FEmailSignUpNAMEViewController"];
    rootViewController.delegate = self;
    rootViewController.location = location;
    [self.pageViewController setViewControllers:@[rootViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

-(void)SignUpNAMEClickedBack:(FEmailSignUpNAMEViewController *)controller{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FirstLaunch" bundle:nil];
    FPageFOURViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"FPageFOURViewController"];
    rootViewController.delegate = self;
    [self.pageViewController setViewControllers:@[rootViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

-(void)SignUpNAMEClickedNext:(FEmailSignUpNAMEViewController *)controller withLocation:(NSMutableDictionary *)location andName:(NSString *)name{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FirstLaunch" bundle:nil];
    FEmailSignUpEMAILViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"FEmailSignUpEMAILViewController"];
    rootViewController.delegate = self;
    rootViewController.location = location;
    rootViewController.name = name;
    [self.pageViewController setViewControllers:@[rootViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

-(void)SignUpEMAILClickedBack:(FEmailSignUpEMAILViewController *)controller withLocation:(NSMutableDictionary *)location andName:(NSString *)name{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FirstLaunch" bundle:nil];
    FEmailSignUpNAMEViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"FEmailSignUpNAMEViewController"];
    rootViewController.delegate = self;
    rootViewController.location = location;
    rootViewController.name = name;
    [self.pageViewController setViewControllers:@[rootViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

-(void)SignUpEMAILClickedNext:(FEmailSignUpEMAILViewController *)controller withLocation:(NSMutableDictionary *)location name:(NSString *)name andEmail:(NSString *)email{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FirstLaunch" bundle:nil];
    FEmailSignUpPASSWORDViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"FEmailSignUpPASSWORDViewController"];
    rootViewController.delegate = self;
    rootViewController.location = location;
    rootViewController.name = name;
    rootViewController.email = email;
    [self.pageViewController setViewControllers:@[rootViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

-(void)SignUpPASSWORDClickedBack:(FEmailSignUpPASSWORDViewController *)controller withLocation:(NSMutableDictionary *)location name:(NSString *)name email:(NSString *)email{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FirstLaunch" bundle:nil];
    FEmailSignUpEMAILViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"FEmailSignUpEMAILViewController"];
    rootViewController.delegate = self;
    rootViewController.location = location;
    rootViewController.name = name;
    rootViewController.email = email;
    [self.pageViewController setViewControllers:@[rootViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}


@end
