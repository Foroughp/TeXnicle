//
//  TPProjectBuilder.m
//  TeXnicle
//
//  Created by Martin Hewitson on 30/7/11.
//  Copyright 2011 bobsoft. All rights reserved.
//
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

#import "TPProjectBuilder.h"
#import "ConsoleController.h"
#import "NSString+LaTeX.h"
#import "NSString+RelativePath.h"
#import "ProjectEntity.h"
#import "FolderEntity.h"
#import "FileEntity.h"
#import "TeXFileEntity.h"
#import "ProjectItemTreeController.h"
#import "MHFileReader.h"
#import "NSString+FileTypes.h"
#import "TPProjectBuilderReport.h"
#import "TPRegularExpression.h"
#import "NSArray_Extensions.h"

#define PROJECT_BUILDER_DEBUG 0

@interface TPProjectBuilder ()

@property (copy) NSString *projectName;
@property (copy) NSString *projectDir;
@property (copy) NSString *mainfile;
@property (strong) NSMutableArray *filesOnDiskList;
@property (strong) NSMutableAttributedString *reportString;

@end

@implementation TPProjectBuilder

+ (TeXProjectDocument*) buildProjectInDirectory:(NSString*)path withName:(NSString*)aName
{
  NSFileManager *fm = [NSFileManager defaultManager];
  TPProjectBuilder *pb = [TPProjectBuilder builderWithDirectory:path];
  if (aName != nil && [aName length] > 0) {
    pb.projectName = aName;
  }
  
  // check if the project already exists and ask the user if they want to overwrite it
  // Remove file if it is there
  NSString *docpath = [pb.projectFileURL path];
  if ([fm fileExistsAtPath:docpath]) {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@".yyyy_MM_dd_HH_mm_ss"];
    NSString *movedPath = [docpath stringByAppendingFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"A TeXnicle Project Already Exists"
                                     defaultButton:@"Continue"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@"A project file called %@ already exists in %@.\nIf you continue, the exiting project file will be moved to:\n%@.", [docpath lastPathComponent], [docpath stringByDeletingLastPathComponent], [movedPath lastPathComponent]];
    
    NSInteger result = [alert runModal];
    
    if (result == NSAlertAlternateReturn) {
      return nil;
    }
    
    NSError *moveError = nil;
    [fm moveItemAtPath:docpath toPath:movedPath error:&moveError];
    if (moveError) {
      [NSApp presentError:moveError];
      return nil;
    }
  }
  
  [TeXProjectDocument createTeXnicleProjectAtURL:pb.projectFileURL];
  NSError *openError = nil;
  TeXProjectDocument *doc = [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:pb.projectFileURL display:YES error:&openError];
  if (openError) {
    [NSApp presentError:openError];
    return nil;
  }
  [pb populateDocument:doc];
  
  return doc;
}

+ (TeXProjectDocument*) buildProjectInDirectory:(NSString*)path
{
  return [TPProjectBuilder buildProjectInDirectory:path withName:nil];
}

// Convenience constructor
+ (TPProjectBuilder*)builderWithDirectory:(NSString*)aPath
{
  return [[TPProjectBuilder alloc] initWithDirectory:aPath];
}

// Inialise the builder with the given directory
- (id) initWithDirectory:(NSString*)aPath
{
  NSString *file = [TPProjectBuilder mainfileForDirectory:aPath];
  if (!file)
    return nil;
  
  self = [self initWithMainfile:file];
  if (self) {
  }
  return self;
}

// Convenience constructor
+ (TPProjectBuilder*)builderWithMainfile:(NSString*)aFile
{
  return [[TPProjectBuilder alloc] initWithMainfile:aFile];
}

// Initialise the builder with the given main file.
- (id) initWithMainfile:(NSString*)aFile
{
  self = [super init];
  if (self) {
    self.mainfile = [aFile lastPathComponent];
    self.projectDir = [aFile stringByDeletingLastPathComponent];
    self.projectName = [[aFile lastPathComponent] stringByDeletingPathExtension];
    self.filesOnDiskList = [NSMutableArray array];
  }
  return self;
}


// Look for the first tex file which has a \begin{document} in it and return that file.
+ (NSString*) mainfileForDirectory:(NSString*)aPath
{
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error = nil;
  NSArray *results = [fm contentsOfDirectoryAtPath:aPath error:&error];
  if (results == nil) {
    [NSApp presentError:error];
    return nil;
  }
  
  // look at each item in the directory
  for (NSString *path in results) {
    NSString *fullpath = [aPath stringByAppendingPathComponent:path];
    // look for files
    NSDictionary *atts = [fm attributesOfItemAtPath:fullpath error:&error];
    if (atts) {
      if ([atts fileType] == NSFileTypeRegular) {
        NSError *error = nil;
        // load the file as a string
        error = nil;
        
        MHFileReader *fr = [[MHFileReader alloc] init];
        NSString *str = [fr readStringFromFileAtURL:[NSURL fileURLWithPath:fullpath]];
        
        if (str) {
          // look for \documentclass
          NSString *scanned = nil;
          NSScanner *scanner = [NSScanner scannerWithString:str];
          [scanner scanUpToString:@"\\documentclass" intoString:&scanned];
          if ([scanner scanLocation] < [str length]) {
            // we found the string
            return fullpath;
          }
        }
      }
    }
  }
  
  // warn that no main file was found
  NSAlert *alert = [NSAlert alertWithMessageText:@"Main File Not Found"
                                   defaultButton:@"OK"
                                 alternateButton:nil
                                     otherButton:nil
                       informativeTextWithFormat:@"No file was found containing a \\documentclass command"];
  [alert runModal];
  
  return nil;
}

// Generate a list of relative file paths to the files contained in the project dir.
- (void)generateFileList
{
  [self.filesOnDiskList removeAllObjects];
  [self gatherFilesRelativeTo:self.projectDir];
}

// Gather a list of files relative to the given path
- (void)gatherFilesRelativeTo:(NSString*)aPath
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  NSFileManager *fm = [NSFileManager defaultManager];
  NSError *error = nil;
  NSArray *results = [fm contentsOfDirectoryAtPath:aPath error:&error];
  for (NSString *path in results) {
    NSString *fullpath = [aPath stringByAppendingPathComponent:path];
    NSDictionary *atts = [fm attributesOfItemAtPath:fullpath error:&error];
    if (atts) {
      if ([atts fileType] == NSFileTypeRegular) {
        if ([[sfm supportedExtensions] containsObject:[fullpath pathExtension]] || [fullpath pathIsImage]) {
          NSString *relative = [self.projectDir relativePathTo:fullpath];
          [self.filesOnDiskList addObject:relative];
        }
      } else if ([atts fileType] == NSFileTypeDirectory) {
        [self gatherFilesRelativeTo:fullpath];
      }
    }
  }
}

// Returns a file in the 'files on disk' array that matches the given argument. File extensions are ignored. Only the last path component (file name) is compared.
- (NSString*)fileForArgument:(NSString*)arg
{
#if PROJECT_BUILDER_DEBUG
  NSLog(@"Getting file for argument %@", arg);
#endif
  
  // check for exact match
  for (NSString *file in self.filesOnDiskList) {
    // do we need to compare extension?
    if ([file isEqualToString:arg]) {
      return file;
    }
  }
  
  // if we didn't find an exact match, check for a match without extension
  for (NSString *file in self.filesOnDiskList) {
    NSString *name = [[file lastPathComponent] stringByDeletingPathExtension];
    if ([name isEqualToString:[[arg lastPathComponent] stringByDeletingPathExtension]]) {
      return file;
    }
  }
  
  return nil;
}


// The tags to search for.
- (NSArray*)includeTags
{
  return [[NSArray texIncludeCommandsSearchStrings] arrayByAddingObject:@"\\includegraphics"];
}

// follow all includes etc from main file and populate the document project
- (void)populateDocument:(TeXProjectDocument*)aDocument
{
  [self generateFileList];
#if PROJECT_BUILDER_DEBUG
  NSLog(@"%@", self.filesOnDiskList);
#endif
  if (self.mainfile) {
    NSString *mainFilePath = [self.projectDir stringByAppendingPathComponent:self.mainfile];
    ProjectEntity *project = [aDocument project];
    NSManagedObjectContext *moc = [aDocument managedObjectContext];
    FileEntity *file = [self addFileAtPath:mainFilePath toFolder:nil inProject:project inMOC:moc];
    // set as main file
    [project setValue:file forKey:@"mainFile"];
    self.reportString = [[NSMutableAttributedString alloc] init];
    [self document:aDocument addProjectItemsFromFile:mainFilePath];
    [file setValue:@0 forKey:@"sortIndex"];
    if ([self.reportString length] > 0) {
      
      // show error messages in console
      [[ConsoleController sharedConsoleController] showWindow:self];
      [[ConsoleController sharedConsoleController] error:[self.reportString string]];
      
    }
  }
  [aDocument.projectItemTreeController updateSortOrder];
}

// Add project items by scanning the given file string.
- (void)document:(TeXProjectDocument*)aDocument addProjectItemsFromFile:(NSString*)aFile
{
  TPSupportedFilesManager *sfm = [TPSupportedFilesManager sharedSupportedFilesManager];
  ProjectEntity *project = [aDocument project];
  //  NSFileManager *fm = [NSFileManager defaultManager];
  NSManagedObjectContext *moc = [aDocument managedObjectContext];
	NSCharacterSet *ws = [NSCharacterSet whitespaceCharacterSet];
	NSCharacterSet *ns = [NSCharacterSet newlineCharacterSet];
  // load the file as a string
  MHFileReader *fr = [[MHFileReader alloc] init];
  NSString *string = [fr readStringFromFileAtURL:[NSURL fileURLWithPath:aFile]];
  if (string == nil) {
    [[ConsoleController sharedConsoleController] error:[NSString stringWithFormat:@"Failed to load contents of file %@", aFile]];
  } else {
    
    string = [TPRegularExpression stringByReplacingOccurrencesOfRegex:@"\n" withString:@" " inString:string];
    string = [@" " stringByAppendingString:string];
    
    // scan through looking for each include tag
    NSUInteger loc = 0;
    while (loc < [string length]) {
      if ([ws characterIsMember:[string characterAtIndex:loc]] ||
          [ns characterIsMember:[string characterAtIndex:loc]]) {
        
        NSString *word = [string nextWordStartingAtLocation:&loc];
        word = [word stringByTrimmingCharactersInSet:ws];
        
        // check if this word matches any of the tags
        for (NSString *tag in [self includeTags]) {
          if ([word hasPrefix:tag]) {
#if PROJECT_BUILDER_DEBUG
            NSLog(@"%ld, Matched tag %@ with word %@", loc, tag, word);
#endif
            // get argument to this include tag
            
            // we need a longer string here, we should probably pass the full string and a start index
            // to look for the argument
            NSInteger argStart = loc-[word length];
            NSString *arg = [string parseArgumentStartingAt:&argStart];
#if PROJECT_BUILDER_DEBUG
            NSLog(@"Got arg %@", arg);
#endif
            
            if (arg != nil && [arg length]>0) {
              
              
              
              // Now we have a name, we need to find it on disk, because we don't know what kind of file it is
              NSString *filearg  = [self fileForArgument:arg];
#if PROJECT_BUILDER_DEBUG
              NSLog(@"Got file argument %@", filearg);
#endif
              if (!filearg) {
                NSString *str = [NSString stringWithFormat:@"Couldn't find included file on disk: %@\n", [self.projectDir stringByAppendingPathComponent:arg]];
                NSMutableAttributedString *astr = [[NSMutableAttributedString alloc] initWithString:str];
                [astr addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, 36)];
                [self.reportString appendAttributedString:astr];
                continue;
              }
              
              NSString *fullpath = [[self.projectDir stringByAppendingPathComponent:filearg] stringByStandardizingPath];
#if PROJECT_BUILDER_DEBUG
              NSLog(@"Full path %@", fullpath);
#endif
              
              if ([project fileWithPathOnDisk:fullpath]) {
                // then the project already contains the file and we don't import it.
                NSString *str = [NSString stringWithFormat:@"Project already contains the file: %@\n", fullpath];
                NSMutableAttributedString *astr = [[NSMutableAttributedString alloc] initWithString:str];
                [astr addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, [str length])];
                [self.reportString appendAttributedString:astr];
#if PROJECT_BUILDER_DEBUG
                NSLog(@"### Skipping %@, it's already there", fullpath);
#endif
              } else {
                if ([[sfm supportedExtensions] containsObject:[fullpath pathExtension]] || [fullpath pathIsImage]) {
#if PROJECT_BUILDER_DEBUG
                  NSLog(@"+ Adding %@", fullpath);
#endif
                  NSString *relativePath = [[[self.projectDir relativePathTo:fullpath] stringByDeletingLastPathComponent] stringByStandardizingPath];
                  NSArray *pathComps = [relativePath pathComponents];
                  
                  // Make folders for each path component, if required
                  FolderEntity *folder = [self makeFoldersForComponents:pathComps inProject:project inMOC:moc];
                  
                  // add file
                  FileEntity *file = [self addFileAtPath:fullpath toFolder:folder inProject:project inMOC:moc];
                  if (file) {
                    // if this is a tex file, recursive call
                    if ([[file extension] isEqualToString:@"tex"]) {
                      [self document:aDocument addProjectItemsFromFile:[file pathOnDisk]];
                    }
                  } else {
                    NSString *str = [NSString stringWithFormat:@"Failed to add file: %@\n", fullpath];
                    NSMutableAttributedString *astr = [[NSMutableAttributedString alloc] initWithString:str];
                    [astr addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, [str length])];
                    [self.reportString appendAttributedString:astr];
                  }
                } else {
                  NSString *str = [NSString stringWithFormat:@"Not adding unsupported file type: %@\n", fullpath];
                  NSMutableAttributedString *astr = [[NSMutableAttributedString alloc] initWithString:str];
                  [astr addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, [str length])];
                  [self.reportString appendAttributedString:astr];
#if PROJECT_BUILDER_DEBUG
                  NSLog(@"-- file is not supported or image: %@", fullpath);
#endif
                }
              }
            }
          }
        } // end loop over tags
      } // end if starting a word
      loc++;
    } // end while loop
  } // end if file load was successful
}

// Add a file at the given path to the given project.
- (FileEntity*) addFileAtPath:(NSString*)fullpath toFolder:(FolderEntity*)folder inProject:(ProjectEntity*)project inMOC:(NSManagedObjectContext*)moc
{
  NSString *extension = [fullpath pathExtension];
  
  
  // check if the file was a text file
	BOOL isTextFile = NO;
	if ([[fullpath pathExtension] isText]) {
		isTextFile = YES;
	}
  
	// if file is text, before making the file in the project, ensure we can read it from disk
  NSData *data = nil;
  if (isTextFile) {
    // set file content
    MHFileReader *fr = [[MHFileReader alloc] init];
    NSString *contents = [fr readStringFromFileAtURL:[NSURL fileURLWithPath:fullpath]];
    if (contents == nil) {
#if PROJECT_BUILDER_DEBUG
      NSLog(@"File contents nil for %@", fullpath);
#endif
      return nil;
    }
    
    data = [contents dataUsingEncoding:[fr encodingUsed]];
    
    if (data == nil) {
#if PROJECT_BUILDER_DEBUG
      NSLog(@"File contents data nil for %@", fullpath);
#endif
      return nil;
    }
  }
  
  FileEntity *newFile;
	NSEntityDescription *entity = nil;
	if ([extension isEqual:@"tex"]) {
		entity = [NSEntityDescription entityForName:@"TeXFile" inManagedObjectContext:moc];
	} else {
		entity = [NSEntityDescription entityForName:@"File" inManagedObjectContext:moc];
	}
	
	newFile = [[FileEntity alloc] initWithEntity:entity
                insertIntoManagedObjectContext:moc];
  
	// set the parent object
  [newFile setParent:folder];
  
	[moc processPendingChanges];
	
  [newFile setValue:data forKey:@"content"];
  
	// set project
	[newFile setValue:project forKey:@"project"];
	
  // set extension
  [newFile setValue:extension forKey:@"extension"];
  
	// set name
	[newFile setValue:[fullpath lastPathComponent] forKey:@"name"];
	
	// set isText
	[newFile setValue:@(isTextFile) forKey:@"isText"];
  
	// configure the textstorage
	[newFile reconfigureDocument];
  
	// Set the filepath to the given one, or to the path in the project
  [newFile setValue:fullpath forKey:@"filepath"];
	
  // load icon
  [newFile loadIcon];
  
	// set file load data
	[newFile setValue:[NSDate date] forKey:@"fileLoadDate"];
	[newFile setValue:[NSDate date] forKey:@"lastEditDate"];
  
  return newFile;
}


// Make folders in the project for the given path components.
- (FolderEntity*) makeFoldersForComponents:(NSArray*)pathComps inProject:(ProjectEntity*)project inMOC:(NSManagedObjectContext*)moc
{
#if PROJECT_BUILDER_DEBUG
  NSLog(@"Making folder for %@", pathComps);
#endif
  NSString *lastComp = nil;
  FolderEntity *parentItem = nil;
  for (NSString *comp in pathComps) {
    
    NSString *filepath = nil;
    if (lastComp == nil) {
      filepath = comp;
    } else {
      filepath = [lastComp stringByAppendingPathComponent:comp];
    }
    
    // get a list of current folders in the project to check against
    NSArray *folders = [project folders];
#if PROJECT_BUILDER_DEBUG
    NSLog(@"  checking for %@", filepath);
#endif
    BOOL createFolder = YES;
    for (FolderEntity *folder in folders) {
#if PROJECT_BUILDER_DEBUG
      NSLog(@"     path: %@", [folder pathRelativeToProject]);
#endif
      if ([filepath isEqualToString:[folder pathRelativeToProject]]) {
        // skip making this one
        createFolder = NO;
        parentItem = folder;
        break;
      }
    }
    
    if (createFolder) {
      // make the folder
      NSEntityDescription *newFolderEntity = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:moc];
      FolderEntity *newFolder = [[FolderEntity alloc] initWithEntity:newFolderEntity insertIntoManagedObjectContext:moc];
      
      // set name
      [newFolder setValue:comp forKey:@"name"];
      
      // set project
      [newFolder setValue:project forKey:@"project"];
      
      // set parent
      [newFolder setParent:parentItem];
      
#if PROJECT_BUILDER_DEBUG
      NSLog(@"Adding new folder: %@", newFolder);
#endif
      parentItem = newFolder;
    }
    lastComp = comp;
  } // end loop over path components
  return parentItem;
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"ProjectBuilder: %@, %@, %@", self.projectName, self.projectDir, self.mainfile];
}

- (NSURL*)projectFileURL
{
  return [NSURL fileURLWithPath:[self.projectDir stringByAppendingPathComponent:[self.projectName stringByAppendingPathExtension:@"texnicle"]]];
}

@end
