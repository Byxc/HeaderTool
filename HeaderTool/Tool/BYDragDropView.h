//
//  BYDragDropView.h
//  BYAppIconTool
//
//  Created by fuyoufang on 2017/10/11.
//  Copyright © 2017年 byxc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol BYDragDropViewDelegate <NSObject>

@optional
- (void)disposeDragingFiles:(NSArray *)files;

@end

@interface BYDragDropView : NSView

@property(nonatomic, weak)id<BYDragDropViewDelegate> delegate;
@property(nonatomic, copy)void(^disposeDraginFilesHandle)(NSArray *files);

@end
