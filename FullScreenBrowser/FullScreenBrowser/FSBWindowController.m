//
//  FSBWindowController.m
//  FullScreenBrowser
//
//  Created by Patrick Tescher on 9/4/12.
//  Copyright (c) 2012 WillCall. All rights reserved.
//

#import "FSBWindowController.h"

static NSString *defaultURL = @"http://www.getwillcall.com";
static const NSInteger maxWebviews = 16;

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

- (NSSet*)webViews {
    if (_webViews) {
        return _webViews;
    } else {
        _webViews = [[NSMutableSet alloc] initWithCapacity:maxWebviews];
    }
    return _webViews;
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
        if (![self.webViews containsObject:subview]) {
            [self.webViews addObject:subview];
        }
    } else if (subview.subviews.count > 0) {
        for (NSView *subSubView in subview.subviews) {
            [self loadDefaultURLForSubviewsIn:subSubView];
        }
    }
}

- (WebView*)webViewAtMouse {
    NSPoint mousePoint = [self.window mouseLocationOutsideOfEventStream];
    
    for (WebView *webView in self.webViews) {
        NSPoint relativePoint = [webView convertPoint:mousePoint fromView:nil];
        NSLog(@"Checking if relative point %@ is in this webview", NSStringFromPoint(relativePoint));
        NSView *hitView = [webView hitTest:relativePoint];
        if (hitView) {
            NSLog(@"Found web view at %@", NSStringFromPoint([webView convertPoint:webView.frame.origin toView:self.view]));
            return webView;
        }
    }
    NSLog(@"No view found for %@", NSStringFromPoint(mousePoint));
    return nil;
}

- (void)setURL {
    [[self window] setLevel:NSNormalWindowLevel];
    NSAlert *alert = [NSAlert alertWithMessageText:@"Enter URL"
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];

    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:@"http://"];
    [alert setAccessoryView:input];

    WebView *hitView = [self webViewAtMouse];
    if (hitView) {
        [alert beginSheetModalForWindow:self.window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void *)hitView.superview.superview];
    }
}

- (void)autoLayoutSplitView:(NSSplitView*)splitView {
    if (splitView.subviews.count > 1) {
        float size = 0;
        if (splitView.isVertical) {
            size = splitView.frame.size.width;
        } else if (!splitView.isVertical) {
            size = splitView.frame.size.height;
        }
        for(int i = 0; i < splitView.subviews.count - 1; i++) {
            [splitView setPosition:size / splitView.subviews.count ofDividerAtIndex:i];
        }
    } else {
        NSLog(@"Split view has no divider");
    }
}

- (void)splitViewVertically:(BOOL)vertical {
    if (self.webViews.count <= maxWebviews) {
        WebView *hitView = [self webViewAtMouse];
        if (hitView) {
            WebView *webView = (WebView*)hitView.superview.superview;
            if ([webView.superview isKindOfClass:[NSSplitView class]] && [(NSSplitView*)webView.superview isVertical] == vertical) {
                WebView *newWebView = [[WebView alloc] initWithFrame:webView.frame];
                [self.webViews addObject:newWebView];
                [[newWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:defaultURL]]];
                [webView.superview addSubview:newWebView];
                [self autoLayoutSplitView:(NSSplitView*)webView.superview];
                NSLog(@"Added subview, split view now has %li views", webView.superview.subviews.count);
            } else {
                NSSplitView *splitView = [[NSSplitView alloc] initWithFrame:webView.frame];
                if (vertical) {
                    [splitView setVertical:TRUE];
                } else {
                    [splitView setVertical:FALSE];
                }
                [webView.superview addSubview:splitView];
                WebView *newWebView = [[WebView alloc] initWithFrame:webView.frame];
                [self.webViews addObject:newWebView];
                [[newWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:defaultURL]]];
                [splitView addSubview:webView];
                [splitView addSubview:newWebView];
                [self autoLayoutSplitView:splitView];
                NSLog(@"Split webview, split view now has %li views", splitView.subviews.count);
            }
        }
        NSLog(@"We now have %li views", self.webViews.count);
    } else {
        NSLog(@"Hit max already!");
    }
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    if ([(__bridge id)contextInfo isKindOfClass:[WebView class]]) {
        [[(__bridge WebView*)contextInfo mainFrame] loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[(NSTextField*)alert.accessoryView stringValue]]]];
    }

    [[self window] setLevel:NSNormalWindowLevel];
}

@end
