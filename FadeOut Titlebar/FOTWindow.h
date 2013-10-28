//
//  FOTWindow.h
//  FadeOut Titlebar
//
//  Created by Guilherme Rambo on 27/10/13.
//  Copyright (c) 2013 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FOTWindowFrame;

@interface FOTWindow : NSWindow

@property (nonatomic, strong) FOTWindowFrame *fullContentView;

// adds a subview that stays below the titlebar
// notice: all views in this window will get wantsLayer = YES
- (void)addSubviewBelowTitlebar:(NSView *)subview;

@end

@interface FOTWindowFrame : NSView

@property (nonatomic,assign) BOOL isDocument;

@end

@interface FOTWindowTitle : NSView

@property (nonatomic,assign) BOOL isDocument;

@end