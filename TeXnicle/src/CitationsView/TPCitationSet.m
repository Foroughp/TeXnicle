//
//  TPCitationSet.m
//  TeXnicle
//
//  Created by Martin Hewitson on 17/7/12.
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

#import "TPCitationSet.h"
#import "FileEntity.h"

@implementation TPCitationSet


- (void) setCitationsFromBibliographyArray:(NSArray*)aList
{
  NSMutableArray *newLabels = [NSMutableArray array];
  for (BibliographyEntry *entry in aList) {
    TPCitation *l = [TPCitation citationWithFile:self.file entry:entry];
    [newLabels addObject:l];
  }
  self.items = [NSArray arrayWithArray:newLabels];
}

- (NSAttributedString*)selectedDisplayString
{
  return [self stringForDisplayWithColor:[NSColor alternateSelectedControlTextColor] detailsColor:[NSColor alternateSelectedControlTextColor]];
}

- (NSAttributedString*)displayString
{
  return [self stringForDisplayWithColor:[NSColor darkGrayColor] detailsColor:[NSColor lightGrayColor]];
}



@end
