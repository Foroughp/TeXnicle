//
//  TPSectionListController.h
//  TeXnicle
//
//  Created by Martin Hewitson on 27/3/10.
//  Copyright 2010 bobsoft. All rights reserved.
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

#import <Cocoa/Cocoa.h>

@protocol TPSectionListControllerDelegate <NSObject>

- (NSArray*)bookmarksForCurrentFile;

@end

@interface TPSectionListController : NSObject {
@private
	NSMenu *addMarkerActionMenu;
  NSCharacterSet *whiteSpace;
  NSCharacterSet *newlines;
}

@property (unsafe_unretained) NSTextView *textView;
@property (unsafe_unretained) NSPopUpButton *popupMenu;
@property (unsafe_unretained) id<TPSectionListControllerDelegate> delegate;

- (id) initWithDelegate:(id<TPSectionListControllerDelegate>)aDelegate;

- (void) deactivate;
- (IBAction)calculateSections:(id)sender;
- (IBAction) gotoSection:(id)sender;
- (void)fillSectionMenu;

- (void) createMarkerMenu;
- (void) addSelectedMarker:(id)sender;
- (IBAction) addMarkAction:(id)sender;
- (void) addTitle;

- (void) tearDown;
- (void) setup;

@end

