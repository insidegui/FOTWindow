//
//  AppDelegate.h
//  FadeOut Titlebar
//
//  Created by Guilherme Rambo on 27/10/13.
//  Copyright (c) 2013 Guilherme Rambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FOTWindow;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet FOTWindow *window;

@end
