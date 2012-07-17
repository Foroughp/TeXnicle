//
//  TPSpellCheckFileOperation.m
//  TeXnicle
//
//  Created by Martin Hewitson on 16/7/12.
//  Copyright (c) 2012 bobsoft. All rights reserved.
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

#import "TPSpellCheckFileOperation.h"
#import "FileEntity.h"
#import "NSString+Spelling.h"

@implementation TPSpellCheckFileOperation

@synthesize delegate;
@synthesize words = _words;

- (id) initWithDelegate:(id<TPSpellCheckFileDelegate>)aDelegate;
{
  self = [super init];
  if (self) {
    self.delegate = aDelegate;
  }
  return self;
}

- (void) dealloc
{
  NSLog(@"Dealloc %@", self);
  self.words = nil;
//  [_words release];
  [super dealloc];
}

//- (NSArray*)words
//{
//  return _words;
//}

-(void)main {
  @try {
    
    NSMutableArray *someWords = [[NSMutableArray alloc] init];
    
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    
    if ([self isCancelled]) return;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(spellCheckFileOperationTextToCheck:)]) {
      NSString *text = [[self.delegate spellCheckFileOperationTextToCheck:self] copy];
      if (text) {
        NSArray *misspelledWords = [text listOfMisspelledWords];
        for (id word in misspelledWords) {
          [someWords addObject:word];
        }
        if ([self isCancelled]) return;
        
      }
    }
    
    [pool drain];
    
    if ([self isCancelled]) return;
    self.words = someWords;
    [someWords release];
    
    if (self.words) {
      if ([self.delegate respondsToSelector:@selector(spellCheckFileOperationDidCompleteCheck:)]) {
        [self.delegate performSelectorOnMainThread:@selector(spellCheckFileOperationDidCompleteCheck:) withObject:self waitUntilDone:YES];
      }
    }
    
  }
  @catch(...) {
    // Do not rethrow exceptions.
  }
}

@end
