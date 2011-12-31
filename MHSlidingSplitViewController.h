//
//  MHSlidingSplitViewController.h
//  TestSlidingSplitView
//
//  Created by Martin Hewitson on 30/12/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHSlidingSplitViewController : NSObject <NSSplitViewDelegate> {
@private
  NSSplitView *splitView;
  BOOL rightSided;
  BOOL _sidePanelIsVisible;
  NSView *inspectorView;
  NSView *mainView;
  CGFloat lastInspectorWidth;
}

@property (assign) IBOutlet NSSplitView *splitView;
@property (assign) IBOutlet NSView *inspectorView;
@property (assign) IBOutlet NSView *mainView;
@property (assign) BOOL rightSided;


- (IBAction)toggle:(id)sender;
- (IBAction)slideOut:(id)sender;
- (void) slideOutAnimated:(BOOL)animate;
- (IBAction)slideIn:(id)sender;
- (void) slideInAnimated:(BOOL)animate;


@end
