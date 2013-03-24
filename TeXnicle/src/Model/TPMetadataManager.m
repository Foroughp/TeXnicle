//
//  TPMetadataManager.m
//  TeXnicle
//
//  Created by Martin Hewitson on 23/3/13.
//  Copyright (c) 2013 bobsoft. All rights reserved.
//

#import "TPMetadataManager.h"
#import "TPFileMetadata.h"

NSString * const TPFileMetadataSectionsUpdatedNotification = @"TPFileMetadataSectionsUpdatedNotification";
NSString * const TPFileMetadataUpdatedNotification = @"TPFileMetadataUpdatedNotification";
NSString * const TPMetadataManagerDidBeginUpdateNotification = @"TPMetadataManagerDidBeginUpdateNotification";
NSString * const TPMetadataManagerDidEndUpdateNotification = @"TPMetadataManagerDidEndUpdateNotification";

@interface TPMetadataManager ()

@property (strong) NSTimer *timer;
@property (assign) NSInteger updatingCount;

@end

@implementation TPMetadataManager

- (id) initWithDelegate:(id<MetadataManagerDelegate>)aDelegate
{
  self = [super init];
  if (self) {
    self.delegate = aDelegate;
    self.files = [[NSMutableArray alloc] init];
  }
  
  return self;
}

- (void) tearDown
{
  [self stop];
}

- (void) start
{
  [self stop];
  [self setupTimer];
}

- (void) setupTimer
{
  self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                target:self
                                              selector:@selector(update)
                                              userInfo:nil
                                               repeats:YES];
  
}


- (void) stop
{
  //  NSLog(@"Stopping metadata timer for %@", self);
  if (self.timer) {
    [self.timer invalidate];
    self.timer = nil;
  }
}


- (void) update
{
  if (self.updatingCount > 0) {
    return;
  }
  
  //NSLog(@"Metadata Manager update triggered on thread %@", [NSThread currentThread]);
  
  
  // get list of files from delegate
  NSArray *filesToUpdate = [self metadataManagerFilesToScan:self];
  self.updatingCount = 0;
  for (TPFileMetadata *f in filesToUpdate) {
    if (f.needsUpdate) {
      f.delegate = self;
      [f updateMetadata];
      self.updatingCount++;
    }
  }
  
  if (self.updatingCount > 0) {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:TPMetadataManagerDidBeginUpdateNotification object:self];
  }
}


#pragma mark -
#pragma mark FileMetadata Delegate

- (void) fileMetadataDidUpdate:(TPFileMetadata *)file
{
  self.updatingCount--;

  if (self.updatingCount == 0) {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:TPMetadataManagerDidEndUpdateNotification object:self];
  }
}

#pragma mark -
#pragma mark Delegate

- (NSArray*) metadataManagerFilesToScan:(TPMetadataManager *)manager
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(metadataManagerFilesToScan:)]) {
    return [self.delegate performSelector:@selector(metadataManagerFilesToScan:) withObject:self];
  }
  
  return @[];
}

@end
