//
//  FSBWindowController.m
//  FullScreenBrowser
//
//  Created by Patrick Tescher on 9/4/12.
//  Copyright (c) 2012 WillCall. All rights reserved.
//

#import "FSBWindowController.h"

static NSString *defaultURL = @"http://www.getwillcall.com";
static const NSInteger maxWebviews = 120;

@interface FSBWindowController ()

@end

@implementation FSBWindowController
@synthesize view;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.window.backgroundColor = [NSColor blackColor];
    [self loadDefaultURLForSubviewsIn:[self view]];
}

- (void)loadDefaultURLForSubviewsIn:(NSView*)subview {
    if ([subview isKindOfClass:[WebView class]]) {
        [[(WebView*)subview mainFrame] loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:defaultURL]]];
    } else if (subview.subviews.count > 0) {
        for (NSView *subSubView in subview.subviews) {
            [self loadDefaultURLForSubviewsIn:subSubView];
        }
    }
}

- (BOOL)view:(NSView*)aView isSubviewOf:(NSView*)aSuperview {
    if (aView.superview == aSuperview) {
        return TRUE;
    } else {
        if (aView.superview) {
            return [self view:aView.superview isSubviewOf:aSuperview];
        }
    }
    return FALSE;
}

- (WebView*)firstWebViewSuperviewOfView:(NSView*)aView {
    NSLog(@"Checking a %@ for its superview", [aView class]);
    if (aView.superview == nil) {
        return nil;
    }
    
    if ([aView.superview isKindOfClass:[WebView class]]) {
        return (WebView*)aView.superview;
    } else {
        return [self firstWebViewSuperviewOfView:aView.superview];
    }
}

- (WebView*)webViewAtMouse {
    NSPoint mousePosition = [self.window mouseLocationOutsideOfEventStream];
    NSView *activeView = [self.view hitTest:[self.view convertPoint:mousePosition fromView:nil]];
    return [self firstWebViewSuperviewOfView:activeView];
}

- (void)setURLUnderMouse {
    WebView *activeView = [self webViewAtMouse];
    if (activeView) {
        [[self window] setLevel:NSNormalWindowLevel];
        activeView.alphaValue = 0.5;
        NSAlert *alert = [NSAlert alertWithMessageText:@"Enter URL"
                                         defaultButton:@"OK"
                                       alternateButton:@"Cancel"
                                           otherButton:nil
                             informativeTextWithFormat:@""];

        NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
        [input setStringValue:@"http://"];
        [alert setAccessoryView:input];

        [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void *)activeView];
    }
}

- (void)splitWebViewUnderMouseVertically:(BOOL)vertical {
    WebView *activeView = [self webViewAtMouse];
    if (activeView) {
        activeView.alphaValue = 0.5;
        WebView *webView = (WebView*)activeView;
        if ([webView.superview isKindOfClass:[NSSplitView class]] && [(NSSplitView*)webView.superview isVertical] == vertical) {
            WebView *newWebView = [[WebView alloc] initWithFrame:webView.frame];
            [[newWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:defaultURL]]];
            [webView.superview addSubview:newWebView];
            [(NSSplitView*)webView.superview adjustSubviews];
            NSLog(@"Split view now has %li views", webView.superview.subviews.count);
        } else {
            NSView *superView = webView.superview;
            NSSplitView *splitView = [[NSSplitView alloc] initWithFrame:webView.frame];
            if (vertical) {
                [splitView setVertical:TRUE];
            } else {
                [splitView setVertical:FALSE];
            }

            WebView *newWebView = [[WebView alloc] initWithFrame:webView.frame];
            [[newWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:defaultURL]]];
            [splitView addSubview:webView];
            [splitView addSubview:newWebView];
            [splitView adjustSubviews];
            
            [superView addSubview:splitView];
            NSLog(@"Split view now has %li views", splitView.subviews.count);
        }
        activeView.alphaValue = 1.0;
    }
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if ([(__bridge id)contextInfo isKindOfClass:[WebView class]]) {
        [(__bridge WebView*)contextInfo setAlphaValue:1.0];
        [[(__bridge WebView*)contextInfo mainFrame] loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[(NSTextField*)alert.accessoryView stringValue]]]];
    } else {
        NSLog(@"Got a %@ back", [(__bridge id)contextInfo class]);
    }

    [[self window] setLevel:NSScreenSaverWindowLevel];
}

- (void)refreshBrowserAtMouse {
    WebView *activeView = [self webViewAtMouse];
    if (activeView) {
        [[activeView mainFrame] reloadFromOrigin];
    }
}

- (void)cascadeRemoveSuperviewFromView:(NSView*)aView {
    if (aView.subviews.count == 0 && [aView isKindOfClass:[NSSplitView class]]) {
        NSView *superView = aView.superview;
        [aView removeFromSuperview];
        if (superView) {
            [self cascadeRemoveSuperviewFromView:superView];
        }
    }

}

- (void)deleteBrowserAtMouse {
    WebView *activeView = [self webViewAtMouse];
    if (activeView) {
        NSView *superView = activeView.superview;
        [activeView removeFromSuperview];
        [self cascadeRemoveSuperviewFromView:superView];
    }
}

- (void)makeTextLargerAtMouse {
    WebView *activeView = [self webViewAtMouse];
    if (activeView) {
        [activeView makeTextLarger:self];
    }
}

- (void)makeTextSmallerAtMouse {
    WebView *activeView = [self webViewAtMouse];
    if (activeView) {
        [activeView makeTextSmaller:self];
    }
}


@end
