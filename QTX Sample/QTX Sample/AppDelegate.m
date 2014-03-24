//
//  AppDelegate.m
//  QTX Sample
//
//  Created by Guilherme Rambo on 28/10/13.
//  Copyright (c) 2013 Guilherme Rambo. All rights reserved.
//

// THIS PROJECT IS ONLY COMPATIBLE WITH OSX MAVERICKS, BECAUSE IT USES AVPLAYERVIEW, AVAILABLE TROUGH THE AVKIT FRAMEWORK

#import "AppDelegate.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@implementation AppDelegate
{
    AVPlayerView *_playerView;
    AVPlayer *_player;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)awakeFromNib
{
    _player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:[NSURL URLWithString:@"https://archive.org/download/AppleCommercial/apple-mvp-top_of_the_line-us-20090824_848x480.mov"]]]];
    
    _playerView = [[AVPlayerView alloc] initWithFrame:[self.window.fullContentView frame]];
    [_playerView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_playerView setControlsStyle:AVPlayerViewControlsStyleFloating];
    [_playerView setPlayer:_player];

    [self.window addSubviewBelowTitlebar:_playerView];
}
- (IBAction)play:(id)sender {
    [_player play];
}


@end
