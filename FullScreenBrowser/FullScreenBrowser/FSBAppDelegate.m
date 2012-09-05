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
        [windowController.window setLevel:NSNormalWindowLevel];
        
        [[windowController window] makeKeyAndOrderFront:NSApp];
    }
    NSLog(@"Set up %li windows for %li screens", self.windowControllers.count, [NSScreen screens].count);
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
    NSLog(@"Getting controller at index %li", screenIndex);
    FSBWindowController *destinationController = (FSBWindowController*)[self.windowControllers objectAtIndex:screenIndex];

    return destinationController;
}

- (IBAction)setActiveURL:(id)sender {
    FSBWindowController *destinationController = [self controllerForCurrentMouse];
    [destinationController setURL];
}

- (IBAction)splitHorizontally:(id)sender {
    FSBWindowController *destinationController = [self controllerForCurrentMouse];
    [destinationController splitViewVertically:FALSE];
}

- (IBAction)splitVertically:(id)sender {
    FSBWindowController *destinationController = [self controllerForCurrentMouse];
    [destinationController splitViewVertically:TRUE];
}



@end
