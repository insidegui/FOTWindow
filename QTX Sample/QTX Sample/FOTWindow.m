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

        _originalThemeFrame = [self.contentView superview];
        _originalThemeFrame.wantsLayer = YES;
        
        self.fullContentView = [[FOTWindowFrame alloc] initWithFrame:self.frame];
        self.fullContentView.wantsLayer = YES;
        [_originalThemeFrame addSubview:self.fullContentView positioned:NSWindowBelow relativeTo:_originalThemeFrame.subviews[0]];
        
        [[self standardWindowButton:NSWindowCloseButton] setAlphaValue:0];
        [[self standardWindowButton:NSWindowZoomButton] setAlphaValue:0];
        [[self standardWindowButton:NSWindowMiniaturizeButton] setAlphaValue:0];
        
        [self.fullContentView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [self.fullContentView setFrame:_originalThemeFrame.frame];
    }
    
    return self;
}

- (void)setTitle:(NSString *)aString
{
    [super setTitle:aString];
    [self.fullContentView setNeedsDisplay:YES];
}

- (void)addSubviewBelowTitlebar:(NSView *)subview
{
    [self.fullContentView addSubview:subview positioned:NSWindowBelow relativeTo:self.fullContentView.subviews[0]];
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
    for (NSView *view in _originalThemeFrame.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"NSThemeDocumentButton")] || [view isKindOfClass:NSClassFromString(@"_NSThemeFullScreenButton")]) {
            [view setAlphaValue:0];
            self.fullContentView.isDocument = YES;
        }
    }
}

@end

#define kTitleBarHeight 22.0

@implementation FOTWindowFrame
{
    FOTWindowTitle *_titleBar;
}

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
    [[[self.window standardWindowButton:NSWindowCloseButton] animator] setAlphaValue:1];
    [[[self.window standardWindowButton:NSWindowZoomButton] animator] setAlphaValue:1];
    [[[self.window standardWindowButton:NSWindowMiniaturizeButton] animator] setAlphaValue:1];
    [[_titleBar animator] setAlphaValue:0.9];
    
    for (NSView *view in self.superview.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"NSThemeDocumentButton")] || [view isKindOfClass:NSClassFromString(@"_NSThemeFullScreenButton")]) {
            [[view animator] setAlphaValue:1];
        }
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [[[self.window standardWindowButton:NSWindowCloseButton] animator] setAlphaValue:0];
    [[[self.window standardWindowButton:NSWindowZoomButton] animator] setAlphaValue:0];
    [[[self.window standardWindowButton:NSWindowMiniaturizeButton] animator] setAlphaValue:0];
    [[_titleBar animator] setAlphaValue:0];
    
    for (NSView *view in self.superview.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"NSThemeDocumentButton")] || [view isKindOfClass:NSClassFromString(@"_NSThemeFullScreenButton")]) {
            [[view animator] setAlphaValue:0];
        }
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor clearColor] setFill];
    NSRectFill(dirtyRect);
    
    NSBezierPath *framePath = [NSBezierPath bezierPathWithRoundedRect:self.frame xRadius:4 yRadius:4];
    
    [[NSColor blackColor] setFill];
    [framePath addClip];
    NSRectFill(self.frame);
}

- (void)setIsDocument:(BOOL)isDocument
{
    _isDocument = isDocument;
    _titleBar.isDocument = isDocument;
    [_titleBar setNeedsDisplay:YES];
}

@end

@implementation FOTWindowTitle

// draws the title bar background and window title
- (void)drawRect:(NSRect)dirtyRect
{
    NSColor* fillColor = [NSColor colorWithCalibratedRed: 0.076 green: 0.073 blue: 0.076 alpha: 1];
    NSColor* strokeColor = [NSColor colorWithCalibratedRed: 0.289 green: 0.289 blue: 0.289 alpha: 1];
    NSColor* gradientColor = [NSColor colorWithCalibratedRed: 0.179 green: 0.179 blue: 0.179 alpha: 1];
    NSColor* shadowColor2 = [NSColor colorWithCalibratedRed: 0.719 green: 0.714 blue: 0.719 alpha: 1];

    NSGradient* gradient = [[NSGradient alloc] initWithColorsAndLocations:
                            strokeColor, 0.0,
                            gradientColor, 0.50,
                            fillColor, 0.51, nil];

    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: shadowColor2];
    [shadow setShadowOffset: NSMakeSize(0.1, -1.1)];
    [shadow setShadowBlurRadius: 0];

    CGFloat roundedRectangleCornerRadius = 4;
    NSRect roundedRectangleRect = NSMakeRect(0, 0, NSWidth(self.frame), kTitleBarHeight);
    NSRect roundedRectangleInnerRect = NSInsetRect(roundedRectangleRect, roundedRectangleCornerRadius, roundedRectangleCornerRadius);
    NSBezierPath* roundedRectanglePath = [NSBezierPath bezierPath];
    [roundedRectanglePath moveToPoint: NSMakePoint(NSMinX(roundedRectangleRect), NSMinY(roundedRectangleRect))];
    [roundedRectanglePath lineToPoint: NSMakePoint(NSMaxX(roundedRectangleRect), NSMinY(roundedRectangleRect))];
    [roundedRectanglePath appendBezierPathWithArcWithCenter: NSMakePoint(NSMaxX(roundedRectangleInnerRect), NSMaxY(roundedRectangleInnerRect)) radius: roundedRectangleCornerRadius startAngle: 0 endAngle: 90];
    [roundedRectanglePath appendBezierPathWithArcWithCenter: NSMakePoint(NSMinX(roundedRectangleInnerRect), NSMaxY(roundedRectangleInnerRect)) radius: roundedRectangleCornerRadius startAngle: 90 endAngle: 180];
    [roundedRectanglePath closePath];
    
    [gradient drawInBezierPath: roundedRectanglePath angle: -90];

    NSRect rectangleBorderRect = NSInsetRect([roundedRectanglePath bounds], -shadow.shadowBlurRadius, -shadow.shadowBlurRadius);
    rectangleBorderRect = NSOffsetRect(rectangleBorderRect, -shadow.shadowOffset.width, -shadow.shadowOffset.height);
    rectangleBorderRect = NSInsetRect(NSUnionRect(rectangleBorderRect, [roundedRectanglePath bounds]), -1, -1);
    
    NSBezierPath* rectangleNegativePath = [NSBezierPath bezierPathWithRect: rectangleBorderRect];
    [rectangleNegativePath appendBezierPath: roundedRectanglePath];
    [rectangleNegativePath setWindingRule: NSEvenOddWindingRule];
    
    [NSGraphicsContext saveGraphicsState];
    {
        NSShadow* shadowWithOffset = [shadow copy];
        CGFloat xOffset = shadowWithOffset.shadowOffset.width + round(rectangleBorderRect.size.width);
        CGFloat yOffset = shadowWithOffset.shadowOffset.height;
        shadowWithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
        [shadowWithOffset set];
        [[NSColor grayColor] setFill];
        [roundedRectanglePath addClip];
        NSAffineTransform* transform = [NSAffineTransform transform];
        [transform translateXBy: -round(rectangleBorderRect.size.width) yBy: 0];
        [[transform transformBezierPath: rectangleNegativePath] fill];
    }
    [NSGraphicsContext restoreGraphicsState];
    
    // TITLE TEXT

    NSColor* fillColor2 = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
    NSColor* strokeColor2 = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 1];

    NSShadow* shadow2 = [[NSShadow alloc] init];
    [shadow2 setShadowColor: strokeColor2];
    [shadow2 setShadowOffset: NSMakeSize(1.1, 1.1)];
    [shadow2 setShadowBlurRadius: 0];

    NSString* textContent = self.window.title;
    
    NSRect textRect;
    if (self.isDocument) {
        textRect = NSMakeRect(20, -2, NSWidth(self.frame)-20, NSHeight(self.frame));
    } else {
        textRect = NSMakeRect(0, -2, NSWidth(self.frame), NSHeight(self.frame));
    }
    
    [NSGraphicsContext saveGraphicsState];
    [shadow2 set];
    NSMutableParagraphStyle* textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [textStyle setAlignment: NSCenterTextAlignment];
    
    NSDictionary* textFontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSFont boldSystemFontOfSize: [NSFont systemFontSize]], NSFontAttributeName,
                                        fillColor2, NSForegroundColorAttributeName,
                                        textStyle, NSParagraphStyleAttributeName, nil];
    
    [textContent drawInRect: textRect withAttributes: textFontAttributes];
    [NSGraphicsContext restoreGraphicsState];
}

@end