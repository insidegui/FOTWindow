//
//  FOTWindow.h
//  FadeOut Titlebar
//
//  Created by Guilherme Rambo on 27/10/13.
//  Copyright (c) 2013 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FOTWindow : NSWindow

@end

@interface FOTWindowFrame : NSView

@property (nonatomic,assign) BOOL isDocument;

@end

@interface FOTWindowTitle : NSView

@property (nonatomic,assign) BOOL isDocument;

@end