//
//  TPStatusViewController.m
//  TeXnicle
//
//  Created by Martin Hewitson on 9/11/11.
//  Copyright (c) 2011 bobsoft. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL MARTIN HEWITSON OR BOBSOFT SOFTWARE BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "TPStatusViewController.h"

@interface TPStatusViewController ()

@property (unsafe_unretained) IBOutlet NSTextField *editorStatusTextField;
@property (unsafe_unretained) IBOutlet NSTextField *filenameTextField;
@property (unsafe_unretained) IBOutlet NSButton *revealButton;
@property (unsafe_unretained) IBOutlet MHToolbarBackgroundView *rightPanel;

@end

@implementation TPStatusViewController

- (id) init
{
  self = [super initWithNibName:@"TPStatusViewController" bundle:nil];
  if (self) {
    // Initialization code here.
    _column = NSNotFound;
  }
  
  return self;
}

- (void) dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  self.editorStatusText = nil;
  self.filenameText = nil;
}

- (void)awakeFromNib
{
  [[self.editorStatusTextField cell] setBackgroundStyle:NSBackgroundStyleRaised];
  [[self.filenameTextField cell] setBackgroundStyle:NSBackgroundStyleRaised];
  
  [self.view setPostsFrameChangedNotifications:YES];
  
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self
         selector:@selector(handleBoundsDidChangeNotification:) 
             name:NSViewFrameDidChangeNotification 
           object:self.view];
  
  [self.rightPanel setStrokeLeftSide:YES];
  
}

- (void)setFilenameText:(NSString *)filenameText
{
  _filenameText = [filenameText copy];
  
  if (_filenameText) {
    if (![_filenameText isEqualToString:[self.filenameTextField stringValue]]) {
      [self.filenameTextField setStringValue:_filenameText];
      [self resizeLabels];
    }
  }
  
}

- (void) handleBoundsDidChangeNotification:(NSNotification*)aNote
{
  [self resizeLabels];
  [self.rightPanel setNeedsDisplay:YES];
}

- (void) resizeLabels
{
  NSRect br = [self.revealButton frame];
  // size to fit
  NSRect cr = [self.rightPanel frame];
  NSSize s = [[self.filenameTextField attributedStringValue] size];
  NSRect r = [self.filenameTextField frame];
  CGFloat w = MIN(10.0 + s.width, cr.size.width - br.size.width - 2.0 - 10.0);
  if (w != r.size.width) {
    [self.filenameTextField setFrameSize:NSMakeSize(w, r.size.height)];
    // move button
    r = [self.filenameTextField frame];
    [self.revealButton setFrameOrigin:NSMakePoint(r.origin.x + r.size.width + 2.0, br.origin.y)];
  }
}

- (void)setEditorStatusText:(NSString *)editorStatusText
{
  _editorStatusText = [editorStatusText copy];
  if (_editorStatusText) {
    if (![_editorStatusText isEqualToString:[self.editorStatusTextField stringValue]]) {
      [self.editorStatusTextField setStringValue:_editorStatusText];
    }
  }
}


- (void)setShowRevealButton:(BOOL)state
{
  _showRevealButton = state;
  [self.revealButton setHidden:!state];
}

- (void) enable:(BOOL)state
{
  [self.revealButton setHidden:!state];
  [self.editorStatusTextField setHidden:!state];
  [self.filenameTextField setHidden:!state];
}

- (IBAction)revealFile:(id)sender
{
  
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	[ws selectFile:self.filenameText inFileViewerRootedAtPath:[self.filenameText stringByDeletingLastPathComponent]];
  
}

- (void) updateDisplay
{
  // status
  NSString *status = nil;
  if (self.lineNumber == NSNotFound) {
    status = [NSString stringWithFormat:@"line: -, char: %ld, col: %ld", self.character, self.column];
  } else {
    status = [NSString stringWithFormat:@"line: %ld, char: %ld, col: %ld", self.lineNumber, self.character, self.column];
  }  
  [self.editorStatusTextField setStringValue:status];
}


@end
