//
//  ExternalTeXDoc.h
//  TeXnicle
//
//  Created by Martin Hewitson on 22/2/10.
//  Copyright 2010 bobsoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPFileMonitor.h"
#import "TeXTextView.h"
#import "TPEngineManager.h"
#import "TPEngineSettingsController.h"

@class TeXEditorViewController;
@class TPStatusView;

@interface ExternalTeXDoc : NSDocument <NSApplicationDelegate, TPFileMonitorDelegate, TeXTextViewDelegate, TPEngineManagerDelegate, TPEngineSettingsDelegate> {

	NSMutableAttributedString *documentData;

	IBOutlet NSWindow *addToProjectSheet;
	IBOutlet NSWindow *addToEmptyProjectSheet;
	
	// Add to project
	IBOutlet NSArrayController *projectsController;
	
	IBOutlet NSButton *copyToProjectCheckButton;
	IBOutlet NSToolbarItem *addToProjectButton;
	
	// Add to new project
	IBOutlet NSButton *copyToNewProjectCheckButton;
	IBOutlet NSButton *makeMainFileCheckButton;
		
  TeXEditorViewController *texEditorViewController;
  NSView *texEditorContainer;
  
  BOOL openPDFAfterBuild;
  TPStatusView *statusView;
  
  NSDate *fileLoadDate;
  TPFileMonitor *fileMonitor;
  
  TPEngineManager *engineManager;
  
  NSView *drawerContentView;
  NSMutableDictionary *settings;
  
  NSProgressIndicator *compileProgressIndicator;
}

@property (retain) NSMutableDictionary *settings;
@property (assign) IBOutlet TPStatusView *statusView;
@property (assign) IBOutlet NSView *drawerContentView;
@property (assign) IBOutlet NSDrawer *drawer;
@property (assign) IBOutlet NSProgressIndicator *compileProgressIndicator;
@property (retain) TPEngineSettingsController *engineSettingsController;

@property(readwrite, assign) NSMutableAttributedString *documentData;
@property (retain) TeXEditorViewController *texEditorViewController;
@property (retain) IBOutlet NSView *texEditorContainer;
@property (retain) NSDate *fileLoadDate;

@property (retain) TPFileMonitor *fileMonitor;

@property (retain) TPEngineManager *engineManager;

- (void) initSettings;
- (void) setupSettings;
- (void) updateFileStatus;
- (void)documentSave:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo;
- (void)documentSaveAndBuild:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo;

#pragma mark -
#pragma mark Notification Handlers

- (void) handleTextSelectionChanged:(NSNotification*)aNote;
- (void) updateCursorInfoText;

#pragma mark -
#pragma mark control

- (IBAction) addToProject:(id)sender;
- (IBAction) endAddToProjectSheet:(id)sender;
- (IBAction) endAddToNewProjectSheet:(id)sender;
- (void) addToNewEmptyProject;
- (void) insertTextToCurrentDocument:(NSString*)string;

#pragma mark -
#pragma mark LaTeX Control

- (IBAction) clean:(id)sender;
- (IBAction) buildAndView:(id)sender;
- (IBAction) buildProject:(id)sender;
- (void) build;
- (void) handleTypesettingCompletedNotification:(NSNotification*)aNote;
- (IBAction) openPDF:(id)sender;

- (NSString*)compiledDocumentPath;

@end

