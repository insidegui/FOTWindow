//
//  FOTWindow.h
//
//  Created by Guilherme Rambo on 27/10/13.
//  Copyright (c) 2013 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FOTWindowFrame;

/**
 View responsible for title bar drawing.
 */
@interface FOTWindowTitle : NSView

@end

/**
 View acting as the window's frame and mouse tracking.
 */
@interface FOTWindowFrame : NSView

@end

/**
 NSWindow subclass to make auto hiding and showing a window's title bar (a la QuickTime X) easier.
 */
@interface FOTWindow : NSWindow

@property (nonatomic, strong) FOTWindowFrame *fullContentView;

/**
 Adds a subview that stays below the title bar. Warning: all views in this window will get wantsLayer = YES.
 */
- (void)addSubviewBelowTitleBar:(NSView *)subview;

/**
 The alpha value the title bar view will be set to when it fades in.
 */
@property CGFloat titleBarFadeInAlphaValue;

/**
 The alpha value the title bar view will be set to when it fades out.
 */
@property CGFloat titleBarFadeOutAlphaValue;

/**
 Block used to specify custom drawing code for a window's title bar.
 @param drawsAsMainWindow Whether the window is in its main state.
 @param drawingRect The entire drawing area of the title bar.
 @param clippingPath Path with the shape of the window title bar's rounded corners (can be used to clip to).
 */
typedef void (^FOTWindowTitleBarDrawingBlock)(BOOL drawsAsMainWindow, NSRect drawingRect, NSBezierPath *clippingPath);

/**
 Specify custom title bar drawing code, which is however responsible for drawing the window's title. If none is specified, the standard OS X titlebar will be drawn.
 */
@property (nonatomic, strong) FOTWindowTitleBarDrawingBlock titleBarDrawingBlock;

@end
