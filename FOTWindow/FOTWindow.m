//
//  FOTWindow.m
//
//  Created by Guilherme Rambo on 27/10/13.
//  Copyright (c) 2013 Guilherme Rambo. All rights reserved.
//

#import "FOTWindow.h"

#define kTitleBarHeight 22.0

@implementation FOTWindowTitle

// Draws the title bar background and window title
- (void)drawRect:(NSRect)dirtyRect
{
    FOTWindow* window = (FOTWindow*)self.window;
    
    CGFloat roundedRectangleCornerRadius = 4;
    NSRect roundedRectangleRect = NSMakeRect(0, 0, NSWidth(self.frame), kTitleBarHeight);
    NSRect roundedRectangleInnerRect = NSInsetRect(roundedRectangleRect, roundedRectangleCornerRadius, roundedRectangleCornerRadius);
    NSBezierPath* clippingPath = [NSBezierPath bezierPath];
    [clippingPath moveToPoint: NSMakePoint(NSMinX(roundedRectangleRect), NSMinY(roundedRectangleRect))];
    [clippingPath lineToPoint: NSMakePoint(NSMaxX(roundedRectangleRect), NSMinY(roundedRectangleRect))];
    [clippingPath appendBezierPathWithArcWithCenter: NSMakePoint(NSMaxX(roundedRectangleInnerRect), NSMaxY(roundedRectangleInnerRect)) radius: roundedRectangleCornerRadius startAngle: 0 endAngle: 90];
    [clippingPath appendBezierPathWithArcWithCenter: NSMakePoint(NSMinX(roundedRectangleInnerRect), NSMaxY(roundedRectangleInnerRect)) radius: roundedRectangleCornerRadius startAngle: 90 endAngle: 180];
    [clippingPath closePath];
    
    BOOL drawsAsMainWindow = (window.isMainWindow && [NSApplication sharedApplication].isActive);
    NSRect drawingRect = NSMakeRect(0, 0, NSWidth(self.frame), kTitleBarHeight);
    
    if (window.titleBarDrawingBlock) {
        // Draw custom titlebar background
        window.titleBarDrawingBlock(drawsAsMainWindow, drawingRect, clippingPath);
    } else {
        // Draw default titlebar background
        NSGradient* gradient;
        if (drawsAsMainWindow) {
            gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.66 alpha:1.0] endingColor:[NSColor colorWithDeviceWhite:0.9 alpha:1.0]];
        } else {
            gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.878 alpha:1.0] endingColor:[NSColor colorWithDeviceWhite:0.976 alpha:1.0]];
        }
        
        [gradient drawInBezierPath:clippingPath angle:90];
        
        // 1px line
        NSRect shadowRect = NSMakeRect(0, 0, NSWidth(self.frame), 1);
        [[NSColor colorWithDeviceWhite:(drawsAsMainWindow)? 0.408 : 0.655 alpha:1.0] set];
        NSRectFill(shadowRect);
    }
    
    if (window.titleDrawingBlock) {
        // Draw custom title
        window.titleDrawingBlock(drawsAsMainWindow, drawingRect);
    } else {
        // Draw default title
        
        // Rect
        NSRect textRect;
        if (window.representedURL) {
            textRect = NSMakeRect(20, -2, NSWidth(self.frame)-20, NSHeight(self.frame));
        } else {
            textRect = NSMakeRect(0, -2, NSWidth(self.frame), NSHeight(self.frame));
        }
        
        // Paragraph style
        NSMutableParagraphStyle* textStyle = [NSMutableParagraphStyle defaultParagraphStyle].mutableCopy;
        [textStyle setAlignment: NSCenterTextAlignment];
        
        // Shadow
        NSShadow* titleTextShadow = [[NSShadow alloc] init];
        titleTextShadow.shadowBlurRadius = 0.0;
        titleTextShadow.shadowOffset = NSMakeSize(0, -1);
        titleTextShadow.shadowColor = [NSColor colorWithDeviceWhite:1.0 alpha:0.5];
        
        NSColor *textColor = [NSColor colorWithDeviceWhite:56.0/255.0 alpha:drawsAsMainWindow? 1.0 : 0.5];
        
        // Draw the title
        NSDictionary* textFontAttributes = @{NSFontAttributeName: [NSFont titleBarFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]],
                                             NSForegroundColorAttributeName: textColor,
                                             NSParagraphStyleAttributeName: textStyle,
                                             NSShadowAttributeName: titleTextShadow};
        
        [window.title drawInRect: textRect withAttributes: textFontAttributes];
    }
}

@end

#pragma mark -

@interface FOTWindowFrame ()

@property (strong) FOTWindowTitle *titleBar;

@end

@implementation FOTWindowFrame

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (self) {
        _titleBar = [[FOTWindowTitle alloc] initWithFrame:NSMakeRect(0, NSHeight(self.frame)-kTitleBarHeight, NSWidth(self.frame), kTitleBarHeight)];
        [_titleBar setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin|NSViewMinXMargin];
        [_titleBar setAlphaValue:0];
        [self addSubview:_titleBar];
    }
    
    return self;
}

- (void)updateTrackingAreas
{
    [super updateTrackingAreas];
    
    [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:self.frame options:NSTrackingActiveAlways|NSTrackingInVisibleRect|NSTrackingMouseEnteredAndExited owner:self userInfo:nil]];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    FOTWindow* window = (FOTWindow*)self.window;
    [[window standardWindowButton:NSWindowCloseButton].animator setAlphaValue:window.titleBarFadeInAlphaValue];
    [[window standardWindowButton:NSWindowZoomButton].animator setAlphaValue:window.titleBarFadeInAlphaValue];
    [[window standardWindowButton:NSWindowMiniaturizeButton].animator setAlphaValue:window.titleBarFadeInAlphaValue];
    [[window standardWindowButton:NSWindowDocumentIconButton].animator setAlphaValue:window.titleBarFadeInAlphaValue];
    [[window standardWindowButton:NSWindowFullScreenButton].animator setAlphaValue:window.titleBarFadeInAlphaValue];
    [[window standardWindowButton:NSWindowDocumentIconButton] setAlphaValue:window.titleBarFadeInAlphaValue];
    [_titleBar.animator setAlphaValue:window.titleBarFadeInAlphaValue];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    FOTWindow* window = (FOTWindow*)self.window;
    [[window standardWindowButton:NSWindowCloseButton].animator setAlphaValue:window.titleBarFadeOutAlphaValue];
    [[window standardWindowButton:NSWindowZoomButton].animator setAlphaValue:window.titleBarFadeOutAlphaValue];
    [[window standardWindowButton:NSWindowMiniaturizeButton].animator setAlphaValue:window.titleBarFadeOutAlphaValue];
    [[window standardWindowButton:NSWindowDocumentIconButton].animator setAlphaValue:window.titleBarFadeOutAlphaValue];
    [[window standardWindowButton:NSWindowFullScreenButton].animator setAlphaValue:window.titleBarFadeOutAlphaValue];
    [[window standardWindowButton:NSWindowDocumentIconButton] setAlphaValue:window.titleBarFadeOutAlphaValue];
    [_titleBar.animator setAlphaValue:window.titleBarFadeOutAlphaValue];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self.window.backgroundColor set];
    NSRectFillUsingOperation(dirtyRect, NSCompositeCopy);
}

@end

#pragma mark -

@implementation FOTWindow
{
    NSView *_originalThemeFrame;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:NO];
    
    if (self) {
        _titleBarFadeInAlphaValue = 1.0;
        _titleBarFadeOutAlphaValue = 0.0;
        
        _originalThemeFrame = [self.contentView superview];
        _originalThemeFrame.wantsLayer = YES;
        
        _fullContentView = [[FOTWindowFrame alloc] initWithFrame:self.frame];
        _fullContentView.wantsLayer = YES;
        [_originalThemeFrame addSubview:_fullContentView positioned:NSWindowBelow relativeTo:_originalThemeFrame.subviews[0]];
        
        [[self standardWindowButton:NSWindowCloseButton] setAlphaValue:_titleBarFadeOutAlphaValue];
        [[self standardWindowButton:NSWindowZoomButton] setAlphaValue:_titleBarFadeOutAlphaValue];
        [[self standardWindowButton:NSWindowMiniaturizeButton] setAlphaValue:_titleBarFadeOutAlphaValue];
        
        [_fullContentView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [_fullContentView setFrame:_originalThemeFrame.frame];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [[self standardWindowButton:NSWindowFullScreenButton] setAlphaValue:_titleBarFadeOutAlphaValue];
}

- (void)becomeKeyWindow
{
    [super becomeKeyWindow];
    [_fullContentView.titleBar setNeedsDisplay:YES];
}

- (void)resignKeyWindow
{
    [super resignKeyWindow];
    [_fullContentView.titleBar setNeedsDisplay:YES];
}

- (void)becomeMainWindow
{
    [super becomeMainWindow];
    [_fullContentView.titleBar setNeedsDisplay:YES];
}

- (void)resignMainWindow
{
    [super resignMainWindow];
    [_fullContentView.titleBar setNeedsDisplay:YES];
}

- (void)setTitle:(NSString *)aString
{
    [super setTitle:aString];
    
    [self.fullContentView setNeedsDisplay:YES];
    [_fullContentView.titleBar setNeedsDisplay:YES];
}

- (void)setRepresentedURL:(NSURL *)url
{
    [super setRepresentedURL:url];
    
    //Match the document icon button to the alpha value of the close button (and the other buttons, essentially)
    [[self standardWindowButton:NSWindowDocumentIconButton] setAlphaValue:[self standardWindowButton:NSWindowCloseButton].alphaValue];
    
    [_fullContentView.titleBar setNeedsDisplay:YES];
}

- (void)addSubviewBelowTitleBar:(NSView *)subview
{
    [_fullContentView addSubview:subview positioned:NSWindowBelow relativeTo:_fullContentView.titleBar];
}

@end