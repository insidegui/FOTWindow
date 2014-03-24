//
//  FOTWindow.m
//  FadeOut Titlebar
//
//  Created by Guilherme Rambo on 27/10/13.
//  Copyright (c) 2013 Guilherme Rambo. All rights reserved.
//

#import "FOTWindow.h"

@implementation FOTWindow
{
    NSView *_originalThemeFrame;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:NSTitledWindowMask|NSClosableWindowMask|NSResizableWindowMask|NSMiniaturizableWindowMask backing:bufferingType defer:NO];
    
    if (self) {
        [self setMovableByWindowBackground:YES];
        
        _titlebarFadeInAlphaValue = 1.0;
        _titlebarFadeOutAlphaValue = 0.0;
        
        _originalThemeFrame = [self.contentView superview];
        _originalThemeFrame.wantsLayer = YES;
        
        self.fullContentView = [[FOTWindowFrame alloc] initWithFrame:self.frame];
        self.fullContentView.wantsLayer = YES;
        [_originalThemeFrame addSubview:self.fullContentView positioned:NSWindowBelow relativeTo:_originalThemeFrame.subviews[0]];
        
        [[self standardWindowButton:NSWindowCloseButton] setAlphaValue:_titlebarFadeOutAlphaValue];
        [[self standardWindowButton:NSWindowZoomButton] setAlphaValue:_titlebarFadeOutAlphaValue];
        [[self standardWindowButton:NSWindowMiniaturizeButton] setAlphaValue:_titlebarFadeOutAlphaValue];
        
        [self.fullContentView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [self.fullContentView setFrame:_originalThemeFrame.frame];
    }
    
    return self;
}

#pragma mark - NSWindow Overrides

- (void)becomeKeyWindow
{
    [super becomeKeyWindow];
    [[self titleBar] setNeedsDisplay:YES];
}

- (void)resignKeyWindow
{
    [super resignKeyWindow];
    [[self titleBar] setNeedsDisplay:YES];
}

- (void)becomeMainWindow
{
    [super becomeMainWindow];
    [[self titleBar] setNeedsDisplay:YES];
}

- (void)resignMainWindow
{
    [super resignMainWindow];
    [[self titleBar] setNeedsDisplay:YES];
}

- (void)setTitle:(NSString *)aString
{
    [super setTitle:aString];
    
    [self.fullContentView setNeedsDisplay:YES];
    
    [[self titleBar] setNeedsDisplay:YES];
}

- (void)addSubviewBelowTitlebar:(NSView *)subview
{
    [self.fullContentView addSubview:subview positioned:NSWindowBelow relativeTo:[self titleBar]];
}

- (FOTWindowTitle*)titleBar {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    FOTWindowTitle* titleBar = [self.fullContentView performSelector:@selector(titleBar)];
    #pragma clang diagnostic pop
    return titleBar;

}

- (void)makeKeyAndOrderFront:(id)sender
{
    [super makeKeyAndOrderFront:sender];
    
    [self hideDocumentButton];
}

- (void)awakeFromNib
{
    [self hideDocumentButton];
}

- (void)hideDocumentButton
{
    [[self standardWindowButton:NSWindowDocumentIconButton] setAlphaValue:0];
    [[self standardWindowButton:NSWindowFullScreenButton] setAlphaValue:0];
    
    self.fullContentView.isDocument = YES;
}

@end


#define kTitleBarHeight 22.0

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
    [[self.window standardWindowButton:NSWindowCloseButton].animator setAlphaValue:window.titlebarFadeInAlphaValue];
    [[self.window standardWindowButton:NSWindowZoomButton].animator setAlphaValue:window.titlebarFadeInAlphaValue];
    [[self.window standardWindowButton:NSWindowMiniaturizeButton].animator setAlphaValue:window.titlebarFadeInAlphaValue];
    [[self.window standardWindowButton:NSWindowDocumentIconButton].animator setAlphaValue:window.titlebarFadeInAlphaValue];
    [[self.window standardWindowButton:NSWindowFullScreenButton].animator setAlphaValue:window.titlebarFadeInAlphaValue];
    [_titleBar.animator setAlphaValue:window.titlebarFadeInAlphaValue];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    FOTWindow* window = (FOTWindow*)self.window;
    [[self.window standardWindowButton:NSWindowCloseButton].animator setAlphaValue:window.titlebarFadeOutAlphaValue];
    [[self.window standardWindowButton:NSWindowZoomButton].animator setAlphaValue:window.titlebarFadeOutAlphaValue];
    [[self.window standardWindowButton:NSWindowMiniaturizeButton].animator setAlphaValue:window.titlebarFadeOutAlphaValue];
    [[self.window standardWindowButton:NSWindowDocumentIconButton].animator setAlphaValue:window.titlebarFadeOutAlphaValue];
    [[self.window standardWindowButton:NSWindowFullScreenButton].animator setAlphaValue:window.titlebarFadeOutAlphaValue];
    [_titleBar.animator setAlphaValue:window.titlebarFadeOutAlphaValue];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self.window.backgroundColor set];
    NSRectFillUsingOperation(dirtyRect, NSCompositeCopy);
}

- (void)setIsDocument:(BOOL)isDocument
{
    _isDocument = isDocument;
    _titleBar.isDocument = isDocument;
    [_titleBar setNeedsDisplay:YES];
}

@end

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
    
    if (window.titleBarDrawingBlock) {
        NSRect drawingRect = NSMakeRect(0, 0, NSWidth(self.frame), kTitleBarHeight);
        window.titleBarDrawingBlock(drawsAsMainWindow, drawingRect, clippingPath);
        
    } else {
        //Draw default titlebar background
        NSGradient* gradient;
        if (drawsAsMainWindow) {
            gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.66 alpha:1.0] endingColor:[NSColor colorWithDeviceWhite:0.9 alpha:1.0]];
        } else {
            gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.878 alpha:1.0] endingColor:[NSColor colorWithDeviceWhite:0.976 alpha:1.0]];
        }
        
        [gradient drawInBezierPath:clippingPath angle:90];
        
        //1px line
        NSRect shadowRect = NSMakeRect(0, 0, NSWidth(self.frame), 1);
        [(drawsAsMainWindow)? [NSColor colorWithDeviceWhite:0.408 alpha:1.0] : [NSColor colorWithDeviceWhite:0.655 alpha:1.0] set];
        NSRectFill(shadowRect);
        
        
        //Draw title
        
        //Rect
        NSRect textRect;
        if (self.isDocument) {
            textRect = NSMakeRect(20, -2, NSWidth(self.frame)-20, NSHeight(self.frame));
        } else {
            textRect = NSMakeRect(0, -2, NSWidth(self.frame), NSHeight(self.frame));
        }
        
        //Pragraph style
        NSMutableParagraphStyle* textStyle = [NSMutableParagraphStyle defaultParagraphStyle].mutableCopy;
        [textStyle setAlignment: NSCenterTextAlignment];
        
        //Shadow
        NSShadow* titleTextShadow = [[NSShadow alloc] init];
        titleTextShadow.shadowBlurRadius = 0.0;
        titleTextShadow.shadowOffset = NSMakeSize(0, -1);
        titleTextShadow.shadowColor = [NSColor colorWithDeviceWhite:1.0 alpha:0.5];
        
        NSColor *textColor = drawsAsMainWindow? [NSColor colorWithDeviceWhite:56.0/255.0 alpha:1.0] : [NSColor colorWithDeviceWhite:56.0/255.0 alpha:0.5];
        
        //Draw it
        NSDictionary* textFontAttributes = @{NSFontAttributeName: [NSFont titleBarFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]],
                                             NSForegroundColorAttributeName: textColor,
                                             NSParagraphStyleAttributeName: textStyle,
                                             NSShadowAttributeName: titleTextShadow};
        
        [self.window.title drawInRect: textRect withAttributes: textFontAttributes];
    }
}

@end