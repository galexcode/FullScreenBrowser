//
//  FSBWindowController.h
//  FullScreenBrowser
//
//  Created by Patrick Tescher on 9/4/12.
//  Copyright (c) 2012 WillCall. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface FSBWindowController : NSWindowController

@property (weak) IBOutlet NSView *view;

- (void)setURLUnderMouse;
- (void)splitWebViewUnderMouseVertically:(BOOL)vertical;
- (void)refreshBrowserAtMouse;
- (void)deleteBrowserAtMouse;
- (void)makeTextLargerAtMouse;
- (void)makeTextSmallerAtMouse;

@end
