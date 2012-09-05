//
//  FSBAppDelegate.m
//  FullScreenBrowser
//
//  Created by Patrick Tescher on 9/4/12.
//  Copyright (c) 2012 WillCall. All rights reserved.
//

#import "FSBAppDelegate.h"
#import "FSBWindowController.h"

@implementation FSBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self.windowControllers removeAllObjects];
    for (NSScreen *screen in [NSScreen screens]) {
        NSRect windowRect = screen.frame;
        windowRect.origin = CGPointMake(0, 0);

        FSBWindowController *windowController = [[FSBWindowController alloc] initWithWindowNibName:@"FSBWindowController"];
        [self.windowControllers addObject:windowController];

        [windowController.window setFrame:screen.frame display:YES];
        [windowController.window setLevel:NSScreenSaverWindowLevel];
        
        [[windowController window] makeKeyAndOrderFront:NSApp];
    }
    NSLog(@"Set up %li windows for %li screens", self.windowControllers.count, [NSScreen screens].count);
    [[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkMouseIdleTime:) userInfo:nil repeats:YES] fire];
}


- (void)checkMouseIdleTime:(NSTimer*)aNotification
{
    CFTimeInterval mouseIdleTime = CGEventSourceSecondsSinceLastEventType(kCGEventSourceStateCombinedSessionState, kCGEventMouseMoved);
    if (mouseIdleTime >= 3)
    {
        [NSCursor setHiddenUntilMouseMoves:YES];
    }
}

- (NSMutableArray*)windowControllers {
    if (_windowControllers) {
        return _windowControllers;
    } else {
        _windowControllers = [[NSMutableArray alloc] initWithCapacity:[NSScreen screens].count];
        return _windowControllers;
    }
}

- (FSBWindowController*)controllerForCurrentMouse {
    NSPoint mouseLoc = [NSEvent mouseLocation];
    NSEnumerator *screenEnum = [[NSScreen screens] objectEnumerator];
    NSScreen *screen;
    while ((screen = [screenEnum nextObject]) && !NSMouseInRect(mouseLoc, [screen frame], NO));

    NSInteger screenIndex = [[NSScreen screens] indexOfObject:screen];
    FSBWindowController *destinationController = (FSBWindowController*)[self.windowControllers objectAtIndex:screenIndex];

    if (destinationController == nil) {
        NSLog(@"No controller found");
    }

    return destinationController;
}

- (IBAction)setActiveURL:(id)sender {
    FSBWindowController *destinationController = [self controllerForCurrentMouse];
    [destinationController setURLUnderMouse];
}

- (IBAction)splitHorizontally:(id)sender {
    FSBWindowController *destinationController = [self controllerForCurrentMouse];
    [destinationController splitWebViewUnderMouseVertically:FALSE];
}

- (IBAction)splitVertically:(id)sender {
    FSBWindowController *destinationController = [self controllerForCurrentMouse];
    [destinationController splitWebViewUnderMouseVertically:TRUE];
}

- (IBAction)refreshBrowser:(id)sender {
    FSBWindowController *destinationController = [self controllerForCurrentMouse];
    [destinationController refreshBrowserAtMouse];
}

- (IBAction)deleteBrowser:(id)sender {
    FSBWindowController *destinationController = [self controllerForCurrentMouse];
    [destinationController deleteBrowserAtMouse];
}

- (IBAction)makeTextLarger:(id)sender {
    FSBWindowController *destinationController = [self controllerForCurrentMouse];
    [destinationController makeTextLargerAtMouse];
}

- (IBAction)makeTextSmaller:(id)sender {
    FSBWindowController *destinationController = [self controllerForCurrentMouse];
    [destinationController makeTextSmallerAtMouse];
}



@end
