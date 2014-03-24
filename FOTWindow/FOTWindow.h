//
//  FOTWindow.h
//  FadeOut Titlebar
//
//  Created by Guilherme Rambo on 27/10/13.
//  Copyright (c) 2013 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FOTWindowFrame;


/* Window Titlebar */
@interface FOTWindowTitle : NSView

@property (nonatomic, assign) BOOL isDocument;

@end


/* NSWindow subclass to make auto hiding and showing (a la QuickTime X) a window's titlebar easier. */
@interface FOTWindow : NSWindow

@property (nonatomic, strong) FOTWindowFrame *fullContentView;

/**
 Adds a subview that stays below the titlebar. Warning: all views in this window will get wantsLayer = YES.
 */
- (void)addSubviewBelowTitlebar:(NSView *)subview;

/**
 The alpha value the titlebar view will be set to when it fades in.
 */
@property CGFloat titlebarFadeInAlphaValue;
/**
 The alpha value the titlebar view will be set to when it fades out.
 */
@property CGFloat titlebarFadeOutAlphaValue;

typedef void (^FOTWindowTitleBarDrawingBlock)(BOOL drawsAsMainWindow, NSRect drawingRect, NSBezierPath *clippingPath);

/**
 Specify custom titlebar drawing code, which is however responsible for drawing the window's title.
 */
@property (nonatomic, strong) FOTWindowTitleBarDrawingBlock titleBarDrawingBlock;

@end


/* Window Frame */
@interface FOTWindowFrame : NSView

@property (nonatomic, assign) BOOL isDocument;

@end

