//
//  BYDragDropView.m
//  BYAppIconTool
//
//  Created by fuyoufang on 2017/10/11.
//  Copyright © 2017年 byxc. All rights reserved.
//

#import "BYDragDropView.h"

@interface BYDragDropView()<NSDraggingDestination>

@end

@implementation BYDragDropView

- (id)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self setOfView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self setOfView];
    }
    return self;
}

- (void)setOfView {
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

#pragma mark - NSDraggingDestination
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    if ([pasteboard.types containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSArray *files = [pasteboard propertyListForType:NSFilenamesPboardType];
    if (_disposeDraginFilesHandle) {
        _disposeDraginFilesHandle(files);
    }
    if (_delegate && [_delegate respondsToSelector:@selector(disposeDragingFiles:)]) {
        [_delegate disposeDragingFiles:files];
    }
    return YES;
}

@end
