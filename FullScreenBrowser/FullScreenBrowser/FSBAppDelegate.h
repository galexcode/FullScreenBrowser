//
//  FSBAppDelegate.h
//  FullScreenBrowser
//
//  Created by Patrick Tescher on 9/4/12.
//  Copyright (c) 2012 WillCall. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FSBAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) NSMutableArray *windowControllers;

- (IBAction)setActiveURL:(id)sender;
- (IBAction)splitHorizontally:(id)sender;
- (IBAction)splitVertically:(id)sender;

@end
